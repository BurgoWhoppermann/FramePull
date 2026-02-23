import SwiftUI

struct BetaSplashView: View {
    let version: String
    let build: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                if let icon = NSApplication.shared.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 72, height: 72)
                }

                Text("Carlo's Clipkit")
                    .font(.title.weight(.bold))

                Text("BETA")
                    .font(.caption.weight(.heavy))
                    .tracking(3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.clipkitBlue)
                    .cornerRadius(4)

                Text("v\(version) · Build \(build)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            // Changelog
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's New")
                        .font(.headline)
                        .foregroundColor(.clipkitBlue)

                    changeGroup("Playback Controls", items: [
                        "Redesigned play & volume buttons — larger floating circles on the video",
                        "Volume slider — click the speaker icon to adjust",
                        "Play button now works in manual mode"
                    ])

                    changeGroup("Scene Detection", items: [
                        "Progress bar now shows in manual mode during detection",
                        "\"Prefer faces\" no longer auto-runs — click Re-generate to refine",
                        "Fixed still markers clustering when using face refinement"
                    ])

                    changeGroup("UI Polish", items: [
                        "Compact inline controls — count, re-generate, duration on fewer rows",
                        "Export toggle cards replace checkboxes",
                        "Both modes share a consistent layout",
                        "Filename and controls overlay on the video player"
                    ])
                }
                .padding(24)
            }

            Divider()
                .padding(.horizontal, 24)

            // Dismiss button
            Button(action: onDismiss) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.clipkitBlue)
            .controlSize(.large)
            .padding(20)
        }
        .frame(width: 380, height: 500)
    }

    private func changeGroup(_ title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.clipkitBlue)
                        .frame(width: 5, height: 5)
                        .padding(.top, 5.5)
                    Text(item)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
