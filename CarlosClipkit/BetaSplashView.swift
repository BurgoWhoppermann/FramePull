import SwiftUI

struct BetaSplashView: View {
    let version: String
    let build: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                .padding(.trailing, 10)
            }

            // Header
            VStack(spacing: 8) {
                if let icon = NSApplication.shared.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 72, height: 72)
                }

                Text("FramePull")
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
            .padding(.top, 0)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            // Changelog
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's New")
                        .font(.headline)
                        .foregroundColor(.clipkitBlue)

                    changeGroup("Face Detection", items: [
                        "\"Prefer faces\" now prompts to run cut detection first",
                        "Face search progress bar with scene-by-scene status",
                        "Results are cached — switching modes doesn't re-scan"
                    ])

                    changeGroup("GIF & Export", items: [
                        "New GIF resolutions: 480w, 720p, 1080p",
                        "GIF quality slider (30–100%)",
                        "Export respects GIF / video clip toggles correctly"
                    ])

                    changeGroup("UI Improvements", items: [
                        "Compact controls bar — legend merged into one row",
                        "Smart still counts when switching placement modes",
                        "Arrow keys scrub ±1 frame, Shift+arrow ±10 frames"
                    ])
                }
                .padding(24)
            }

            // Bug report link
            Button(action: {
                if let url = URL(string: "mailto:mail@carlooppermann.com?subject=FramePull%20Bug%20Report") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "envelope")
                        .font(.caption)
                    Text("Found a bug? Email me at mail@carlooppermann.com")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

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
        .background(KeyDismissHandler(onDismiss: onDismiss))
    }

    /// Invisible NSView that captures key events to dismiss the splash
    private struct KeyDismissHandler: NSViewRepresentable {
        let onDismiss: () -> Void
        func makeNSView(context: Context) -> KeyCaptureView {
            let view = KeyCaptureView()
            view.onKeyDown = onDismiss
            DispatchQueue.main.async { view.window?.makeFirstResponder(view) }
            return view
        }
        func updateNSView(_ nsView: KeyCaptureView, context: Context) {}

        class KeyCaptureView: NSView {
            var onKeyDown: (() -> Void)?
            override var acceptsFirstResponder: Bool { true }
            override func keyDown(with event: NSEvent) {
                // Return(36), Space(49), Escape(53)
                if event.keyCode == 36 || event.keyCode == 49 || event.keyCode == 53 {
                    onKeyDown?()
                } else {
                    super.keyDown(with: event)
                }
            }
        }
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
