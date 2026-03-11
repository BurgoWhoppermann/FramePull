import Foundation
import AVFoundation
import AppKit
import ImageIO
import UniformTypeIdentifiers

class GIFProcessor {

    // Shared utilities (ensureSubdirectory, findNextAvailableIndex, resizeImage) are in ProcessingUtilities.swift

    enum GIFError: LocalizedError {
        case cannotLoadVideo
        case cannotGetDuration
        case cannotCreateDestination(path: String)
        case cannotGenerateFrame(time: CMTime)
        case cannotFinalizeGIF
        case durationTooLong(available: Double)
        case clipTooShort

        var errorDescription: String? {
            switch self {
            case .cannotLoadVideo:
                return "Cannot load the video file. Please ensure it's a valid video format."
            case .cannotGetDuration:
                return "Cannot determine video duration."
            case .cannotCreateDestination(let path):
                return "Cannot create GIF file at: \(path)"
            case .cannotGenerateFrame(let time):
                return "Failed to extract frame at time \(CMTimeGetSeconds(time)) seconds."
            case .cannotFinalizeGIF:
                return "Failed to finalize GIF file."
            case .durationTooLong(let available):
                return "GIF duration exceeds available video length (\(String(format: "%.1f", available)) seconds)."
            case .clipTooShort:
                return "Clip is too short to create a GIF (needs at least 1 frame)."
            }
        }
    }

    func extractGIFs(
        from videoURL: URL,
        clipSpecs: [(start: Double, duration: Double)],
        frameRate: Int,
        resolution: GIFResolution,
        quality: Double = 0.7,
        to outputDirectory: URL,
        lutCubeDimension: Int? = nil,
        lutCubeData: Data? = nil,
        progress: @escaping (Double, String) -> Void
    ) async throws {
        let asset = AVURLAsset(url: videoURL)

        let isReadable = try await asset.load(.isReadable)
        guard isReadable else {
            throw GIFError.cannotLoadVideo
        }

        let videoName = videoURL.deletingPathExtension().lastPathComponent
        let gifSpecs = clipSpecs
        let totalCount = gifSpecs.count

        // Create gifs subdirectory
        let gifsDir = ProcessingUtilities.ensureSubdirectory(outputDirectory, path: "gifs")

        // Find next available index (to append rather than overwrite)
        let startingIndex = ProcessingUtilities.findNextAvailableIndex(in: gifsDir, prefix: "\(videoName)_gif", suffix: ".gif")

        for (gifIndex, spec) in gifSpecs.enumerated() {
            let gifProgress = Double(gifIndex) / Double(totalCount)
            progress(gifProgress, "Creating GIF \(gifIndex + 1) of \(totalCount)...")

            let fileNumber = startingIndex + gifIndex
            let filename = String(format: "%@_gif_%03d.gif", videoName, fileNumber)
            let fileURL = gifsDir.appendingPathComponent(filename)

            try await createGIF(
                from: asset,
                startTime: spec.start,
                duration: spec.duration,
                frameRate: frameRate,
                maxWidth: resolution.maxWidth,
                quality: quality,
                outputURL: fileURL,
                lutCubeDimension: lutCubeDimension,
                lutCubeData: lutCubeData
            ) { frameProgress in
                let overallProgress = gifProgress + (frameProgress / Double(totalCount))
                progress(overallProgress, "Creating GIF \(gifIndex + 1) of \(totalCount) - frame \(Int(frameProgress * Double(frameRate) * spec.duration) + 1)...")
            }
        }

        progress(1.0, totalCount == 0 ? "No scenes long enough for GIFs" : "Complete!")
    }

    private func createGIF(
        from asset: AVURLAsset,
        startTime: Double,
        duration: Double,
        frameRate: Int,
        maxWidth: Int,
        quality: Double,
        outputURL: URL,
        lutCubeDimension: Int? = nil,
        lutCubeData: Data? = nil,
        progress: @escaping (Double) -> Void
    ) async throws {
        let frameCount = Int(duration * Double(frameRate))
        guard frameCount >= 1 else {
            throw GIFError.clipTooShort
        }
        let frameInterval = duration / Double(frameCount)
        let delayTime = 1.0 / Double(frameRate)

        // Set up image generator
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: 0.02, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 0.02, preferredTimescale: 600)
        defer { imageGenerator.cancelAllCGImageGeneration() }

        // Create GIF destination
        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else {
            throw GIFError.cannotCreateDestination(path: outputURL.path)
        }

        // Set GIF properties
        let gifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0  // Loop forever
            ]
        ]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

        // Frame properties with quality
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ],
            kCGImageDestinationLossyCompressionQuality as String: quality
        ]

        // Extract frames and add to GIF
        for frameIndex in 0..<frameCount {
            let frameTime = startTime + (Double(frameIndex) * frameInterval)
            let time = CMTime(seconds: frameTime, preferredTimescale: 600)

            progress(Double(frameIndex) / Double(frameCount))

            do {
                let (cgImage, _) = try await imageGenerator.image(at: time)

                var outputImage = ProcessingUtilities.resizeImage(cgImage, maxWidth: maxWidth)

                // Apply LUT color correction if active
                if let dim = lutCubeDimension, let data = lutCubeData {
                    outputImage = LUTProcessor.applyLUT(to: outputImage, cubeDimension: dim, cubeData: data) ?? outputImage
                }

                CGImageDestinationAddImage(destination, outputImage, frameProperties as CFDictionary)
            } catch {
                throw GIFError.cannotGenerateFrame(time: time)
            }
        }

        // Finalize the GIF
        guard CGImageDestinationFinalize(destination) else {
            throw GIFError.cannotFinalizeGIF
        }
    }

}
