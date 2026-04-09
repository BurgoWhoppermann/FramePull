import SwiftUI

// MARK: - Keyboard Shortcuts Overlay

struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) private var dismiss

    private let shortcuts: [(key: String, action: String)] = [
        ("S", "Snap still frame"),
        ("I", "Mark clip IN point"),
        ("O", "Mark clip OUT point"),
        ("Space", "Play / Pause"),
        ("Delete", "Remove marker at playhead"),
        ("\u{2318}Z", "Undo"),
        ("Esc", "Cancel pending IN point"),
        ("\u{2191}", "Jump to previous marker"),
        ("\u{2193}", "Jump to next marker"),
        ("\u{21E7}\u{2190}", "Skip back 10 frames"),
        ("\u{21E7}\u{2192}", "Skip forward 10 frames"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Shortcuts list
            VStack(spacing: 6) {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { _, shortcut in
                    HStack(spacing: 16) {
                        Text(shortcut.key)
                            .font(.system(.body, design: .monospaced).weight(.semibold))
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .center)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.secondary.opacity(0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                            )

                        Text(shortcut.action)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 2)
                }
            }
            .padding(.vertical, 16)

            Spacer()

            // Dismiss hint
            Text("Press Esc to close")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 14)
        }
        .frame(width: 400, height: 520)
        .onExitCommand { dismiss() }
    }
}
