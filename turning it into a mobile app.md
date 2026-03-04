# FramePull → iOS: Feasibility & Strategy

## The Big Picture

About 65% of FramePull's codebase is pure Swift with no platform ties — all the heavy lifting (scene detection, still/GIF/video export, state management) uses AVFoundation, Vision, CoreImage, and ImageIO, which are fully available on iOS. The remaining 35% is AppKit UI code that needs replacement or redesign.

The core processing engine ports cleanly. The challenge is the interaction model: FramePull is keyboard-driven (S/I/O keys, arrow navigation, Cmd+Z), and that doesn't exist on a phone. An iOS version needs a touch-first interface, not a port of the desktop UI.

---

## What Ports Directly (Zero Changes)

These files compile on iOS as-is:

| File | What it does |
|------|-------------|
| `SceneDetector.swift` | Histogram-based scene detection (Bhattacharyya distance) |
| `GIFProcessor.swift` | Animated GIF export via ImageIO |
| `VideoSnippetProcessor.swift` | MP4 clip export via AVMutableComposition |
| `MarkingState.swift` | Undo/redo stack, marker management |
| `ProcessingUtilities.swift` | Image scaling, aspect ratio cropping (one small fix — see below) |
| `AppState` (in FramePullApp.swift) | All enums, settings, state — pure ObservableObject |

That's the entire processing pipeline and state layer. No rewrites needed.

---

## What Needs Small Fixes

### NSBitmapImageRep → UIImage (VideoProcessor.swift)

The still image exporter uses `NSBitmapImageRep` to encode JPEG/PNG/TIFF. On iOS, swap to `UIImage`:

```swift
// macOS (current)
let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
let data = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])

// iOS (replacement)
let uiImage = UIImage(cgImage: cgImage)
let data = uiImage.jpegData(compressionQuality: 0.9)
```

For PNG: `uiImage.pngData()`. TIFF export doesn't have a one-liner on iOS — could drop TIFF support or use ImageIO directly.

### NSOpenPanel → .fileImporter (ContentView.swift)

```swift
// macOS (current)
let panel = NSOpenPanel()
panel.allowedContentTypes = [.movie, .mpeg4Movie, ...]
panel.runModal()

// iOS (replacement)
.fileImporter(isPresented: $showingPicker, allowedContentTypes: [.movie, .video]) { result in
    // handle URL
}
```

Or pick from the Photos library via `PhotosPicker` (PhotosUI, iOS 16+).

### NSApplication icon references (BetaSplashView, ExportSettingsView)

Replace `NSApplication.shared.applicationIconImage` with a bundled asset or `Image("AppIcon")`.

---

## The Big Redesign: Touch UI

### The Problem

Manual mode is built around keyboard shortcuts:
- **S** = mark still at playhead
- **I** = set clip in-point
- **O** = set clip out-point
- **Arrow keys** = step frame-by-frame or jump between markers
- **Cmd+Z / Cmd+Shift+Z** = undo/redo
- **Space** = play/pause
- **Delete** = remove marker

None of this translates to a phone screen.

### The Solution: On-Screen Controls

Replace the keyboard with a floating control bar beneath the video player:

```
┌─────────────────────────────────────┐
│                                     │
│           VIDEO PLAYER              │
│         (tap to play/pause)         │
│                                     │
├─────────────────────────────────────┤
│  ◀◀  ◀   advancement  ▶  ▶▶        │  ← frame step / jump
├─────────────────────────────────────┤
│  [📷 Still]   [▶ In]   [⏹ Out]    │  ← mark buttons (replaces S/I/O)
├─────────────────────────────────────┤
│  timeline scrubber with markers     │
│  ● ● ●    ●  ●      ●    ●        │
└─────────────────────────────────────┘
```

- **Tap video** → play/pause (replaces Space)
- **Swipe left/right on video** → scrub (replaces arrow keys)
- **Pinch timeline** → zoom in/out for precision
- **Long-press marker** → delete (replaces Delete key)
- **Shake or two-finger tap** → undo (replaces Cmd+Z)

The MarkingState with its undo/redo stack works as-is — only the input triggers change.

### Video Player Replacement

`VideoPlayerRepresentable.swift` wraps `AVPlayerView` (macOS-only) with keyboard capture. On iOS, options are:

1. **SwiftUI `VideoPlayer`** (simplest, iOS 14+) — limited customization
2. **`UIViewControllerRepresentable` + `AVPlayerViewController`** — full transport controls
3. **Custom `AVPlayerLayer` in UIView** — maximum control over overlay UI

Option 3 is best for FramePull because we need the custom marker overlay and scrubber. The player chrome (play/pause, scrubber) should be custom anyway to integrate markers into the timeline.

---

## File I/O on iOS

### The Sandbox Difference

macOS FramePull writes directly to a user-chosen folder (`/stills/`, `/gifs/`, `/videos/`). iOS apps can't write to arbitrary filesystem locations.

### Strategy for iOS

**Input:** `.fileImporter()` for videos from Files app, or `PhotosPicker` for camera roll.

**Output (pick one or combine):**

| Approach | Pros | Cons |
|----------|------|------|
| **Save to Photos** | Familiar, zero friction | Only works for images/video, not GIFs-as-animated |
| **Share sheet** | Universal, user picks destination | One file at a time feels slow for batch export |
| **Files app (Documents dir)** | Batch export works, organized folders | Less discoverable for casual users |
| **Export to folder picker** | Closest to macOS UX | iOS 15+ only, slightly clunky |

**Recommended:** Default to saving stills and clips to the Photos library (`PHPhotoLibrary`). Offer a "Save to Files" option for GIFs and batch exports. Use the share sheet as a fallback for individual files.

---

## Sensible Scoping for iOS v1

### Keep

- **Auto Mode** — scene detection + automatic marker placement. This is the main value prop and it's fully portable.
- **Still export** (JPEG/PNG only, drop TIFF) — most useful output on mobile.
- **Video clip export** — essential, fully portable.
- **Face detection filter** — Vision framework works identically on iOS.
- **Blur rejection** — works as-is.

### Simplify

- **Manual Mode** — include but with touch controls instead of keyboard. Simpler overlay, fewer options.
- **GIF export** — keep but limit to one resolution option (480w) to simplify the UI. Can expand later.
- **Export settings** — reduce to essentials. Mobile users want fewer knobs. Default to JPEG for stills, 1080p for clips.
- **Aspect ratio variants** — keep 4:5 and 9:16 (these are *more* useful on mobile for Instagram/TikTok).

### Drop (for v1)

- **TIFF export** — no real mobile use case.
- **4K clip export** — heavy on phone storage, questionable value. Cap at 1080p initially.
- **Playback speed control** — nice-to-have, add in v2.
- **Drag-and-drop file import** — iOS drag/drop is unreliable. Just use file picker / Photos picker.

### Add (iOS-specific)

- **Camera roll integration** — pick source video from Photos library, save results back.
- **Share sheet** — share any exported file directly to apps.
- **Haptic feedback** — subtle taps when marking stills or setting in/out points.
- **Landscape lock option** — video editing is better in landscape on a phone.

---

## iPhone vs iPad

### iPhone
- Force landscape for the editing view (or at least strongly encourage it).
- Stack controls vertically: video on top, timeline + controls below.
- Simplify to one panel at a time (no sidebars).

### iPad
- Side-by-side layout: video player + settings panel (like macOS but horizontal).
- Support Stage Manager / split-screen multitasking.
- Hardware keyboard support (bring back S/I/O shortcuts as a bonus).
- Apple Pencil: precise timeline scrubbing and marker placement.

Use `@Environment(\.horizontalSizeClass)` to switch between compact (iPhone) and regular (iPad) layouts.

---

## Architecture: Multiplatform vs Separate Target

### Option A: Single Multiplatform Target
Add iOS as a destination in the existing Xcode project. Use `#if os(iOS)` / `#if os(macOS)` for platform-specific UI code. Shared code (processors, state, detection) stays untouched.

**Pros:** One codebase, shared logic automatically.
**Cons:** `#if` blocks get messy, harder to optimize each platform's UX independently.

### Option B: Separate iOS Target, Shared Package
Extract processors, state, and detection into a Swift Package. Each platform target imports the package and has its own UI layer.

**Pros:** Clean separation, each platform gets purpose-built UI.
**Cons:** More upfront setup, package management overhead.

**Recommendation:** Start with Option A (multiplatform target). The shared code is already cleanly separated from UI. Only extract into a package if the `#if` blocks become unmanageable — which is unlikely given there are only ~4 files with platform-specific code.

---

## Effort Breakdown

| Phase | What | Scope |
|-------|------|-------|
| **1. Compile on iOS** | Add iOS target, fix AppKit imports, swap NSBitmapImageRep | Small — a few hours |
| **2. File I/O** | fileImporter, Photos library save, share sheet | Medium — 1-2 days |
| **3. Video Player** | Custom AVPlayerLayer view with touch controls, marker overlay, timeline scrubber | Large — 3-5 days |
| **4. Manual Mode UI** | Touch button bar for S/I/O, gesture-based navigation, undo | Medium — 2-3 days |
| **5. Layout & Polish** | iPhone/iPad adaptive layout, settings views, onboarding | Medium — 2-3 days |
| **6. Testing** | Device testing, performance on older iPhones, edge cases | Medium — 2-3 days |

**Total: ~2-3 weeks for a solid v1.**

The core processing (scene detection, export) will "just work" from day one. The time is almost entirely in building a good touch interface for the video player and marking workflow.

---

## Key Risks

1. **Performance on older iPhones** — Scene detection processes many frames. May need to downsample more aggressively or limit video length on devices with <4GB RAM.
2. **Large video handling** — iPhones shoot 4K/ProRes. Need to test with large files and possibly stream from Photos library rather than copying into sandbox.
3. **Background processing** — iOS suspends apps. Long exports need `BGProcessingTask` or at minimum `UIApplication.shared.beginBackgroundTask()`.
4. **App Store review** — Export-heavy apps sometimes get flagged. Keep the UI clean and the purpose obvious.

---

## Bottom Line

FramePull is well-structured for a port. The processing engine is platform-agnostic, the state management is pure Swift, and the only real work is building a touch-native video editing UI. The biggest decision is how much to simplify the manual mode — keeping it powerful while making it feel natural on a touchscreen is the design challenge. Everything else is mechanical.

---

## Design System Reference

Everything below documents the exact visual language of the macOS app. The iOS version should stay consistent with these values, adapting only where touch targets or screen size demand it.

### Brand Color Palette

All defined as `Color` extensions in `FramePullApp.swift`:

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| `framePullNavy` | `#0A1F3F` | (0.039, 0.122, 0.247) | Deep navy, reserved |
| `framePullAmber` | `#F29E2C` | (0.949, 0.620, 0.173) | Secondary CTA (Generate button), AccentColor in asset catalog |
| `framePullSilver` | `#DFE6ED` | (0.875, 0.902, 0.929) | Light silver, reserved |
| `framePullBlue` | `#4A90D9` | (0.29, 0.56, 0.85) | Primary UI accent — buttons, playhead, active states |
| `framePullLightBlue` | `#4A90D9` @ 10% | — | Hover/selected backgrounds |

```swift
extension Color {
    static let framePullNavy      = Color(red: 0.039, green: 0.122, blue: 0.247)
    static let framePullAmber     = Color(red: 0.949, green: 0.620, blue: 0.173)
    static let framePullSilver    = Color(red: 0.875, green: 0.902, blue: 0.929)
    static let framePullBlue      = Color(red: 0.29, green: 0.56, blue: 0.85)
    static let framePullLightBlue = Color(red: 0.29, green: 0.56, blue: 0.85).opacity(0.1)
}
```

### Semantic Color Roles

| Role | Color | Where |
|------|-------|-------|
| Primary action buttons | `framePullBlue` | Import, Export, Detect Cuts |
| Secondary action | `framePullAmber` | Auto-Generate button |
| Destructive action | `.red` | Reset All |
| Still markers | `.orange` | Timeline dots, key caps, section headers |
| Clip markers | `.green` | Timeline bars, key caps, section headers |
| Scene cut lines | `.secondary` @ 50% | Vertical lines on timeline |
| Playhead | `framePullBlue` | Current position line on timeline |
| Video background | `.black` | Player container fill |
| Panel backgrounds | system `controlBackgroundColor` | Hint bar, controls bar |
| Text primary | `.primary` | Body text (auto dark/light) |
| Text secondary | `.secondary` | Labels, metadata |

### Accent Color (Asset Catalog)

The `AccentColor.colorset` in Assets.xcassets is set to `framePullAmber` — SRGB (0.949, 0.620, 0.173, 1.0). This is the system accent used by default SwiftUI controls.

### Opacity Scale

These values are used consistently throughout the app:

| Opacity | Usage |
|---------|-------|
| 0.1 | Light blue tinted backgrounds |
| 0.12 | Input field / button backgrounds |
| 0.15 | Timeline track background |
| 0.2 | Divider lines, subtle overlays |
| 0.25 | Border strokes |
| 0.35 | Disabled content sections |
| 0.4 | Video player overlay, clip ranges |
| 0.45 | Play button circle background |
| 0.5 | Cut markers, disabled toggle icons |
| 0.6 | Video filename background, clip drag state |
| 0.7 | Generate button glow pulse, key cap glow shadow |
| 0.8 | Text on video overlays, marker shadows |

---

### Typography

The app uses the system font (SF Pro) exclusively — no custom fonts.

| Style | SwiftUI | Weight | Where |
|-------|---------|--------|-------|
| App title | `.title` | `.bold` | "FramePull" in splash |
| Drop zone prompt | `.title2` | `.medium` | "Drop video here" |
| Section action | `.title3` | `.semibold` | "Generate Markers" |
| Section headers | `.headline` | default | "STILLS", "CLIPS" |
| Generate label | `.headline` | `.semibold` | Button text |
| Body text | `.body` | default | Standard paragraphs |
| Button labels | `.body` | `.medium` | "Watch Quick Start Video" |
| Time codes | `.body` | monospaced | `system(.body, design: .monospaced)` |
| Form labels | `.subheadline` | default | Settings field labels |
| Toggle labels | `.subheadline` | `.semibold` | Inline section titles |
| Metadata / hints | `.caption` | default | Instructions, file info |
| BETA label | `.caption` | `.heavy` | With `.tracking(3)` letter spacing |
| Version text | `.caption2` | default | Footer |
| Frame numbers | `.caption2` | monospaced | `system(.caption2, design: .monospaced)` |
| Key caps | `.callout` | monospaced + `.semibold` | S, I, O keyboard hints |

---

### Corner Radii

| Radius | Elements |
|--------|----------|
| 2px | Timeline track, clip ranges, divider handle |
| 4px | Key caps, keyboard shortcut boxes, video title bg, pending clip indicator |
| 6px | Still/clip list items, button containers |
| 8px | Cut detection button, volume popover, drop zone, dialog headers |
| 16px | Drop zone dashed border |
| Circle | Playback buttons (44×44), still markers on timeline |

---

### Shadows & Effects

| Element | Shadow |
|---------|--------|
| Key cap (active) | `color: glowColor.opacity(0.7), radius: 6` |
| Still marker (selected) | `color: .orange.opacity(0.8), radius: 6` |
| Still marker (hovered) | `color: .orange.opacity(0.8), radius: 4` |
| Clip handle (active) | `color: .white.opacity(0.6), radius: 6` |
| Clip handle (hovered) | `color: .white.opacity(0.6), radius: 4` |
| Generate button glow | `color: .framePullAmber.opacity(0.7), radius: 8` (pulsing) |
| Cut detection hover | `scaleEffect(1.05)` — no shadow, just scale |

---

### Spacing System

The app uses explicit spacing values rather than a rigid grid:

**Stack spacing:** 0, 2, 4, 6, 8, 10, 12, 16

| Spacing | Context |
|---------|---------|
| 0 | Main VStack (manual section control) |
| 2 | Very tight: shortcut items |
| 4 | Tight: video title, legend items, list items |
| 6 | Compact: controls bar, inline toggles |
| 8 | Standard: controls sections, popovers |
| 10 | Comfortable: clips settings, analyzer controls |
| 12 | Spacious: generate panel, popovers |
| 16 | Large: main content sections, dialog padding |

**Padding values:** 4, 6, 8, 10, 12, 14, 16, 20, 24 (horizontal and vertical used independently)

---

### Key Dimensions

| Element | Size | Notes |
|---------|------|-------|
| App window min | 480 × 480 | |
| Video player | full width × 300–900px | Resizable via drag divider |
| Timeline track | full width × 56px | Including padding |
| Still marker hit target | 30 × 28px | 10px circle rendered inside |
| Clip handle hit target | 20 × 28px | 6–10px wide handle inside |
| Playback buttons | 44 × 44px | Circular, on video overlay |
| Drag divider | full width × 6px | Between video and controls |
| Export sheet | 400px wide | Auto height |
| Analyzer dialog | 420px wide | Auto height |
| Shortcuts dialog | 400 × 520px | Fixed |
| Cut detection popover | 300px wide | Auto height |
| Splash screen | 380 × 400px | Fixed |

**iOS adaptation:** Touch targets should be minimum 44×44pt (Apple HIG). The existing 44×44 playback buttons are already correct. Still markers (30×28) and clip handles (20×28) need larger touch targets on iOS — recommend 44×44 minimum.

---

### SF Symbols Used

**Navigation & Actions:**
`photo`, `film`, `sparkles`, `xmark.circle.fill`, `xmark`, `play.circle.fill`, `play.rectangle.fill`, `slider.horizontal.3`, `keyboard`, `trash`, `arrow.uturn.backward`, `plus.circle`

**State Indicators:**
`checkmark.circle.fill` (active toggle), `circle` (inactive toggle), `wand.and.stars` (cut detection idle), `scissors` (scene cuts), `circle.dotted` (detection in-progress), `exclamationmark.triangle.fill` (warning, orange tint), `face.smiling` (face count), `magnet` (snap toggle)

**Media Controls:**
`play.fill`, `pause.fill`, `speaker.fill`, `speaker.wave.3.fill`

**Markers:**
`photo.on.rectangle` (stills toggle), `film` (clips toggle), `eye` (seek to marker), `xmark.circle` (remove marker), `arrow.right.circle` (pending clip indicator)

---

### Animations

| Animation | Timing | Where |
|-----------|--------|-------|
| Inline panel appear/disappear | `.move(edge: .top)` + `.opacity` | Generate panel slide in |
| Toggle actions | `.easeInOut(duration: 0.2)` | Checkbox state changes |
| Generate button glow | `.easeInOut(duration: 1.0).repeatForever(autoreverses: true)` | Pulsing amber glow |
| Hover states | `.easeInOut(duration: 0.15)` | Cut detection button, markers |
| State transitions | `.easeInOut(duration: 0.3)` | hasGenerated visibility |
| Key cap active | `.easeOut(duration: 0.15)` | S/I/O glow on/off |
| Generate button scale | `scaleEffect(1.06)` when glowing | Subtle breathing |

**iOS note:** Keep these animations but consider adding haptic feedback (`.impact(.light)`) to accompany marker placement and mode changes.

---

### Dark Mode

The app has no explicit dark/light branching. It works in both modes because:
- Text uses `.primary` / `.secondary` (system-adaptive)
- Panel backgrounds use `NSColor.controlBackgroundColor` (system-adaptive) — on iOS use `Color(UIColor.systemBackground)` and `Color(UIColor.secondarySystemBackground)`
- Video overlays use `.black` with opacity (intentionally dark regardless of mode)
- Brand colors (blue, amber, orange, green) are high-contrast and work on both light and dark backgrounds

The overall aesthetic leans dark — the video player area is always black, and the control panels use system background colors. On iOS, this will naturally look right in both modes.

---

### Layout Structure (macOS → iOS Mapping)

**macOS ManualMarkingView layout (top to bottom):**
```
┌─────────────────────────────────────────┐
│ Marker Hint Bar (S/I/O keys + buttons)  │  → iOS: floating buttons over video
├─────────────────────────────────────────┤
│                                         │
│ Video Player (resizable 300–900px)      │  → iOS: full width, fixed aspect ratio
│ (overlays: cut detection, filename,     │
│  time display, play/pause, volume)      │
│                                         │
├────── drag divider (6px) ───────────────┤  → iOS: remove (no resize needed)
│ Speed | Legend | Undo | Timeline        │  → iOS: compact control strip
├─────────────────────────────────────────┤
│ Pending clip indicator (conditional)    │  → iOS: toast/banner
├─────────────────────────────────────────┤
│ Inline generate panel (conditional)     │  → iOS: bottom sheet
├─────────────────────────────────────────┤
│ ScrollView: stills list + clips list    │  → iOS: scrollable list below controls
├─────────────────────────────────────────┤
│ Export + Shortcuts buttons              │  → iOS: prominent export button
└─────────────────────────────────────────┘
```

**iOS layout (recommended):**
```
┌─────────────────────────────────────────┐
│ Navigation bar (minimal)                │
├─────────────────────────────────────────┤
│                                         │
│ Video Player (16:9, full width)         │
│ (tap to play, overlays preserved)       │
│                                         │
├─────────────────────────────────────────┤
│ Timeline scrubber with markers          │
│ ● ● ●    ●  ●      ●    ●             │
├─────────────────────────────────────────┤
│ ◀◀  ◀   [Still] [In] [Out]   ▶  ▶▶   │  ← action bar
├─────────────────────────────────────────┤
│ ScrollView: marked items               │
│ (stills + clips, swipe to delete)      │
├─────────────────────────────────────────┤
│ [Export All]                            │  ← bottom safe area
└─────────────────────────────────────────┘
```

**iPad layout (recommended, regular size class):**
```
┌──────────────────────────┬──────────────┐
│                          │ Settings     │
│ Video Player             │ / Export     │
│                          │ panel        │
├──────────────────────────┤              │
│ Timeline + controls      │              │
├──────────────────────────┤              │
│ Marked items list        │              │
└──────────────────────────┴──────────────┘
```
