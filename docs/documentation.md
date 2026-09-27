# FramePull — Documentation

> Extract stills, GIFs, video clips, and social-format grids from any video. Fast, local, no subscriptions.

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [The Interface](#2-the-interface)
3. [Cut Detection](#3-cut-detection)
4. [Placing Markers](#4-placing-markers)
   - [Manual Marking](#41-manual-marking)
   - [Auto-Generate](#42-auto-generate)
5. [The Timeline](#5-the-timeline)
6. [LUT Color Grading](#6-lut-color-grading)
7. [The Process Workflow](#7-the-process-workflow)
   - [Review & Select](#71-review--select)
   - [Create Grids](#72-create-grids)
   - [Export](#73-export)
8. [Keyboard Shortcuts](#8-keyboard-shortcuts)
9. [Tips & Workflows](#9-tips--workflows)
10. [iPhone & iPad](#10-iphone--ipad)

---

## 1. Getting Started

1. Launch FramePull. The drop zone appears on first open.
2. **Drag a video file** onto the window, or click **Import…** to browse.
3. Supported formats: MP4, MOV (any codec your Mac can decode).
4. The video loads into the player and you're ready to mark.

---

## 2. The Interface

```
┌─────────────────────────────────────────────────┐
│  [S] [I] [O]   Auto-Generate   Reset All        │  ← Marker bar
├─────────────────────────────────────────────────┤
│                                                 │
│              Video Player                       │  ← Drag bottom edge to resize
│                                                 │
├─────────────────────────────────────────────────┤
│  0.5x  1x  2x   ■ Cuts  ● Auto  ● Manual  Snap │  ← Controls
│  ════════════════timeline══════════════════════ │
│  ▬▬▬▬▬▬▬▬     scroll thumb                     │
├─────────────────────────────────────────────────┤
│  STILLS (3)  ▾                                  │  ← Marker list (scrollable)
│  CLIPS (2)   ▾                                  │
├─────────────────────────────────────────────────┤
│  [ ✨ Process ]                       [⌨]       │  ← Process bar
└─────────────────────────────────────────────────┘
```

The whole window is **resizable** — drag any edge. Full-screen via the green button works too; the UI scales with the available space.

**Video player overlay controls:**

| Control | Action |
|---|---|
| **Detect Cuts** button (top-left) | Open cut detection panel |
| **Filename ×** (top-right) | Remove the current video |
| **▶ / ⏸** (bottom-left) | Play / Pause |
| **🔊** (bottom-left) | Mute toggle; hover to reveal volume slider |
| **Frame / timecode** (bottom-right) | Current position display |
| **Drag divider** (below player) | Resize the player vertically |

---

## 3. Cut Detection

FramePull analyzes your video at its **native frame rate** with zero seek tolerance to find every scene change — cuts land exactly on frame boundaries.

**To detect cuts:**
1. Click the **Detect Cuts** button (top-left of the player).
2. Adjust **Sensitivity** — slide right for more cuts, left for fewer.
3. Click **Detect Cuts** (or **Re-detect**) inside the popover.
4. Progress shows over the player. Cancel anytime via the Cancel button on the overlay.

**After detection**, cut markers (grey ticks) appear on the timeline and the button shows a count (e.g. *"12 Cuts"*).

> **Tip:** Run cut detection before using Auto-Generate or the "Prefer faces" placement mode — both work best when scenes are known.

---

## 4. Placing Markers

### 4.1 Manual Marking

Use keyboard shortcuts while the video plays (or is paused):

| Key | Action |
|---|---|
| `S` | Mark a still at the current frame |
| `I` | Set clip IN point (or close a clip if there's a pending OUT) |
| `O` | Set clip OUT point (or close a clip if there's a pending IN) |
| `Esc` | Cancel a pending IN or OUT marker |
| `Delete` / `Backspace` | Remove marker at current playhead position |
| `Space` | Play / Pause |
| `↑` / `↓` | Jump to previous / next marker |
| `Shift ←` / `Shift →` | Step back / forward 10 frames |
| `Cmd Z` | Undo last action |

You can also click the **S**, **I**, **O** key-cap buttons in the marker bar.

**Bidirectional clip marking** — you can mark a clip in either order:
- **I → O** (forward): hit `I` at the in-point, scrub forward, hit `O` at the out-point.
- **O → I** (reverse): hit `O` at the out-point, scrub back, hit `I` at the in-point.

Both create the same clip `[earlier, later]`. The orange pending indicator below the player shows which side is waiting (`IN: 0:05 → ?` or `? → OUT: 0:12`). Press `Esc` to cancel.

**Snap-to-cut** — when the "Snap" toggle is on, manual markers within **3 source frames** of a detected scene cut land exactly on the cut. IN points sit on the cut frame; OUT points step back by one frame so the cut frame doesn't end up in the exported clip. Beyond 3 frames the marker lands where the playhead/cursor actually is.

### 4.2 Auto-Generate

Click **Auto-Generate** to open the generation panel:

**Stills**
- Toggle **Stills** on/off (affects export, not the markers themselves).
- Set **Count** — total number of stills to place.
- Choose **Placement**:
  - *Spread evenly* — distributed at equal intervals across the full video.
  - *Per scene* — that many stills inside each detected scene.
  - *Prefer faces* — one still per scene, choosing the sharpest frame containing a face (requires cut detection).

**Clips**
- Toggle **Clips** on/off.
- Set **Count** — how many clips to generate.
- **Scenes per clip** — how many consecutive scenes each clip should span (1 = single scene, higher = longer clips crossing multiple scenes).
- **Allow overlapping** — lets generated clips share time ranges.

Click **Generate!** (or **Re-Generate**) to place markers. Manual markers are always preserved; only auto-generated markers are replaced.

> Auto-generated clips use the same frame-based rule as snap: IN at the scene start, OUT one source frame before the next cut.

> **Tip:** You can mix auto and manual markers freely. Auto-generated markers are orange; manual ones are blue.

---

## 5. The Timeline

The timeline below the controls shows the video with all markers overlaid. It uses a **visible-time-window** model — when you zoom in, the visible time range shrinks but the timeline always renders at viewport width.

| Element | Color | Meaning |
|---|---|---|
| Thin grey ticks | Grey | Detected scene cuts |
| Triangle markers | Orange | Auto-generated stills |
| Triangle markers | Blue | Manually placed stills |
| Shaded range bar | Green | Auto-generated clip |
| Shaded range bar | Blue | Manually placed clip |
| Vertical line | Orange | Pending IN or OUT marker |
| Vertical line | Blue | Current playhead |

**Interactions:**
- **Click anywhere** to seek.
- **Drag a still marker** left/right to reposition (snaps to cuts if Snap is on).
- **Drag a clip edge** (IN or OUT handle) to trim.
- **Right-click a marker or clip** to delete it.
- **Double-click a clip** to delete it.
- **Zoom slider** — up to 20×. Zoom anchors on the playhead's screen-fraction position so content under your cursor stays roughly put.
- **Horizontal scroll** — two-finger swipe on trackpad, or Shift + mouse wheel — pans the visible window.
- **Scroll thumb** at the bottom — drag to pan; click on empty track to jump.
- **Auto-page on playback** — when the playhead exits the visible window during play, the window pages forward in one step (playhead lands at 10% from the left). Inside the window the playhead moves freely — no jitter.
- **Loop a clip** — right-click a clip bar and choose Loop, or click the loop icon in the clips list.

---

## 6. LUT Color Grading

Apply a `.cube` LUT file to preview and bake color grades into all exports.

**To apply a LUT:**
1. Click the **LUT** menu in the controls bar (shows current LUT name or "LUT").
2. Choose a **Built-in** LUT or select **Choose LUT Folder…** to load your own `.cube` files.
3. The player updates in real time.
4. All exported stills, GIFs, video clips, and grids will include the color grade.

**To remove a LUT:** Open the LUT menu → select **None**.

**User LUT folders:** FramePull remembers your folder across sessions. To remove a folder, open the LUT menu → **Clear User Folder**.

> Built-in LUTs ship with the app. Place custom `.cube` files in any folder and point FramePull to it.

---

## 7. The Process Workflow

After you've placed markers, click the **Process** button at the bottom of the window. Three phases, freely navigable via the clickable timeline pills at the top of the sheet:

```
[✓ Review & Select]──[2 Create Grids]──[3 Export]
```

You can skip phases. Jumping straight from Review to Export bypasses grid creation; skipping Review uses every marked item as-is.

### 7.1 Review & Select

A thumbnail grid of every marked still and clip. Untick anything you don't want exported.

- **Size picker (S / M / L)** in the top-right — choose your preferred thumbnail size. Persists across launches.
- **Click a thumbnail** to toggle its inclusion (checkbox in the corner).
- **Click again** to open the **lightbox**. Navigate with `←` / `→`.
- **Reframe slider** appears in the lightbox when 4:5 or 9:16 export crops are enabled — drag the image or use the slider to position the crop window. The orange overlay shows exactly what will be cropped.
- **Select All / Deselect All** in the header.

Anything you untick stays in your timeline but won't ship in this export pass.

### 7.2 Create Grids

A composer for stitching approved stills and clips into a single output image or video.

**Toolbar:**
- **Tabs** — multiple grids per session, switch with `⌘1` / `⌘2` / `⌘3` (or click). `+ Add` (or `⌘N`) creates a new grid; the new grid inherits the active grid's layout/ratio.
- **Layout** — 1×1, 1×2, 2×1, 1×3, 3×1, 2×2, 2×3, 3×2.
- **Ratio** — 1:1, 4:5, 9:16, 16:9. Default render is 2160 on the shorter side (true 4K vertical for 9:16).
- **Auto Fill** — distributes approved items evenly across empty slots. Each click re-rolls a different combination, biased to spread across the video timeline. Excludes items already used in other grids first; falls back if needed.
- **Clear** — empties every cell. Layout/ratio stay.
- **Delete** — removes this grid.

**Source pane (left):** every approved still and clip as a small card. The pane is **resizable** — drag the splitter between source and preview.

- **Click** a source → adds to the next empty cell.
- **Drag** a source onto a specific cell → assigns or replaces.
- **Click an in-grid source** → removes from grid; the cell becomes empty in place (other cells don't shift).

**Preview canvas (right):** live render of the grid using the source thumbnails.

- **Drag inside a cell** → pan (live preview, commits on release).
- **Pinch** (trackpad) → zoom 1.0×–4.0×.
- **Scroll wheel** (mouse) → zoom on the hovered cell.
- **Zoom slider** appears on hover at the bottom of the cell.
- **Reset Crop** button (top-right, hover) — only when the cell's been panned/zoomed.
- **Move pill** (top-left, hover) — drag to swap with another cell.
- **Loop pill** (top-right, clip cells only) — click to cycle 1× → 8× → 1×. Sets how many times that clip plays in the video output.
- **Right-click** → Reset Crop · Loop ×N submenu · Remove from Grid.

**Empty cells** are drop targets — drag a source from the pane or a Move pill from another cell onto them.

**What gets exported**:
- All-still grid → **JPEG** (e.g. 2160×3840 for 9:16).
- Any cell is a clip → **MP4** at 30 fps H.264. Duration = `max(clip.duration × loopCount)` across cells; shorter clips loop via modulo.

The same `CellTransform.drawRect` math powers both the preview and the export — WYSIWYG.

### 7.3 Export

The export sheet, embedded in the Process flow with a pinned action bar.

**Summary at top:** `📷 N stills · 🎬 N clips · ⊞ N grids` — counts reflect approved + completed grids.

#### 7.3.1 Stills

| Setting | Options | Notes |
|---|---|---|
| **Format** | JPEG, PNG, TIFF | JPEG = smallest; TIFF = lossless maximum quality |
| **Size** | Full, Half | Scale factor applied to source resolution |

Saved to `<output>/FramePull_<video name>/stills/`.

#### 7.3.2 GIFs

| Setting | Options | Notes |
|---|---|---|
| **Resolution** | 480w, 720p, 1080p | Maximum output width |
| **Frame rate** | 10–30 fps | Higher = smoother but larger file |
| **Quality** | 30–100% | Color palette quality |

Estimated file size per clip updates as you adjust settings. Saved to `<output>/FramePull_<video name>/gifs/`.

#### 7.3.3 Video Clips

| Setting | Options | Notes |
|---|---|---|
| **Quality** | 480p, 720p, 1080p, 4K, Source | Source preserves original resolution |
| **Mute audio** | On / Off | Strips the audio track |

Saved to `<output>/FramePull_<video name>/videos/`.

#### 7.3.4 Aspect Ratio Crops

| Toggle | Ratio | Use case |
|---|---|---|
| **Original** | Source ratio | Always exported (not togglable) |
| **4:5** | 4:5 vertical | Instagram portrait feed |
| **9:16** | 9:16 vertical | Stories, Reels, TikTok |

Cropped variants are saved in subdirectories: `.../4x5/` and `.../9x16/`. Use Review & Select's reframe slider to control the horizontal crop position per item before exporting.

#### 7.3.5 Grids

Toggle **Export grids** to include them. Saved to `<output>/grids/`. Image and video grids share one numbering sequence (`videoname_grid_001.jpg`, `videoname_grid_002.mp4`, …).

#### 7.3.6 Output Folder

Click **Choose…** to select an output folder. FramePull remembers your last choice via a security-scoped bookmark. iCloud Drive paths work.

Everything for one video goes into a `FramePull_<video name>` folder inside the folder you choose. Exporting the same video again reuses that folder and continues the numbering, so you can add more stills later without overwriting what's already there.

If you click **Export** without a folder set, the picker opens automatically and the export kicks off after you choose.

Files are **always added, never overwritten** — sequential numbering (`_001`, `_002`, …) prevents conflicts.

#### 7.3.7 Cancelling

While exporting, the action bar's button switches to a red **Cancel**. Clicking it stops the export cleanly:
- Already-written files stay on disk.
- The in-progress grid file is deleted (no half-written MP4).
- No error alert; the sheet stays open so you can adjust and retry.

---

## 8. Keyboard Shortcuts

### Marking & playback

| Shortcut | Action |
|---|---|
| `S` | Mark still |
| `I` | Set IN point (or close clip if pending OUT) |
| `O` | Set OUT point (or close clip if pending IN) |
| `Space` | Play / Pause |
| `Esc` | Cancel pending IN / OUT |
| `Delete` / `Backspace` | Remove marker at playhead |
| `↑` / `↓` | Jump to previous / next marker |
| `Shift ←` / `Shift →` | Step back / forward 10 frames |
| `Cmd Z` | Undo |
| `Cmd E` | Open Export Settings |

### Grid composer (inside Create Grids)

| Shortcut | Action |
|---|---|
| `⌘ N` | Add a new grid (inherits current layout/ratio) |
| `⌘ 1` / `⌘ 2` / `⌘ 3` | Switch to grid 1 / 2 / 3 |

### Lightbox (Review & Select)

| Shortcut | Action |
|---|---|
| `←` / `→` | Previous / next item |
| `Space` | Open lightbox on hovered item |
| `Esc` | Close lightbox |

Click the **⌨** button (bottom-right of the main window) to view shortcuts in-app.

---

## 9. Tips & Workflows

**Social content workflow**
1. Import your footage → Run cut detection.
2. Click Auto-Generate → set 1 still per scene, Placement = *Prefer faces*.
3. Click **Process** → Review & Select → untick anything weak.
4. Create Grids → pick 1×3, 9:16 → Auto Fill → click each cell to refine the crop.
5. Export. You'll get individual stills + the grid as a 2160×3840 JPEG.

**Quick clip extraction**
1. Play the video, press `I` at a good moment, `O` a few seconds later. Or hit `O` first and `I` later — either works.
2. Repeat for each clip you want.
3. `Cmd E` → choose output folder → Export.

**LUT-baked exports**
1. Load a LUT from the controls bar.
2. The player shows the graded preview in real time.
3. All exports — stills, GIFs, video, grids — include the grade automatically.

**Building a multi-clip reel**
1. Mark a handful of clips (`I` / `O`).
2. Process → skip Review → Create Grids → pick 1×3, 9:16.
3. Auto Fill, then tweak loop counts per clip cell so the output reaches your target duration.
4. Export → one MP4 with all three clips composited and looped.

**Undo**
FramePull tracks every marker change with a 50-step undo stack. Press `Cmd Z` or click the ↩ button to step back. Auto-generation is a single undo step (one undo restores all previous markers). Pan/zoom drags in the grid composer coalesce so a continuous gesture is one undo, not dozens.

**Batch reframing**
Open Review & Select, use arrow keys in the lightbox to cycle through all items, and drag-adjust the crop on each one before closing. Offsets are saved immediately and used at export time.

**Resizing the source pane in Grid Creation**
Drag the splitter between the source pane and the preview canvas to make either side bigger. The position is remembered across launches.

**Zoom on the playhead**
In the timeline, the zoom slider anchors on the playhead's current screen position — content under your cursor stays put as you zoom in. If you've scrolled away from the playhead, zoom anchors on the visible window's centre instead (no jumpy snap-back).

---

## 10. iPhone & iPad

FramePull on iPhone and iPad uses the same cut detection, marking rules and export engine as the Mac — a still or clip marked on a phone lands on exactly the same frame it would on desktop. It's one purchase across all three.

### 10.1 Opening a video

- **Choose from Photos** — where phone footage lives.
- **Browse Files** — for footage synced from a Mac, iCloud Drive or an external drive.
- **Recent** — the last three videos, one tap to reopen.

FramePull keeps its own copy of each video you open, so recents reopen instantly. Those copies are capped at 3 GB in total — the oldest are dropped automatically — and opening the same video again replaces its old copy rather than adding another. The import screen shows how much space the copies use, with a **Clear** button to take it back.

### 10.2 Cut detection

Detection starts as soon as a video opens; the progress bar has a **Stop** button. The **scissors** menu (top right) runs detection again, clears the results, and sets the sensitivity: **Fewer cuts**, **Balanced** (default) or **More cuts**.

### 10.3 Marking

Scrub the timeline, then tap **IN** and **OUT** to mark a clip — either order works — or **STILL** to mark a frame. Markers snap to a cut when you're within 3 frames of it, as on the Mac; turn **Snap** off to place them exactly where the playhead is. **Undo** (↩, top right) steps back through every marker change.

- **Pinch** the timeline to zoom; drag to scrub. While you drag, FramePull shows a quick preview of the frame and settles on the exact one when you let go.
- **Swipe down** on the video, or **double-tap** it, for the **full-screen player**: timeline, transport and IN / OUT / STILL, with everything else out of the way. Controls fade after a few seconds; tap to bring them back. Swipe down, double-tap or tap ⤡ to leave.
- In the marked list, **tap** an item to jump to it, **double-tap a clip to play it on a loop**, and swipe left to delete. **Clear** removes a whole section (undoable).

On iPhone in landscape the controls move to a rail beside the video. On iPad they sit in a sidebar next to the player.

**Hardware keyboard** (Magic Keyboard or any Bluetooth keyboard):

| Key | Action |
|---|---|
| `I` | Set IN point |
| `O` | Set OUT point |
| `S` | Mark still |
| `Space` | Play / Pause |
| `←` / `→` | Step one frame |

### 10.4 Auto-generate

**Auto-generate from N cuts** fills the timeline from the detected cuts: one still in the middle of each scene, and clips spanning 1–4 scenes each (a 3-scene clip contains 2 cuts). Running it again replaces the previous auto markers; ones you placed by hand are kept.

### 10.5 Review

**Review** shows every marker as a card. **Swipe right** (or ✓) to keep, **swipe left** (or ✕) to delete. **Skip review · Keep all** keeps the rest. Deleted markers come back with Undo on the timeline.

### 10.6 Grids

**Grids** opens the composer full screen.

- Pick a **layout** (1×1 to 3×2) and **ratio** (1:1, 4:5, 9:16, 16:9) from the chips at the top.
- **Tap a frame** in the strip at the bottom to drop it into the next empty cell; tap it again to take it out.
- **Drag** inside a cell to reframe it, **pinch** to zoom.
- **Tap a cell** for its zoom slider, **Reset crop**, **Loop ×N** (clip cells) and **Remove**.
- **Hold a cell** and drag it onto another to swap the two.
- **Auto Fill** fills the empty cells; on a full grid it becomes **Re-roll**, which shuffles in a new selection.
- **+** adds another grid; long-press a grid's tab to delete it.

### 10.7 Export

Choose where the results go:

- **Photos Library** — saved into an album named `FramePull_<video name>`; exporting the same video again adds to that album. FramePull asks for photo library access the first time, because finding the album again on the next export means reading the library. If you'd rather not grant that, choose *Don't Allow* and then allow adding photos: everything is still saved, just without the album.
- **Files…** — pick any folder. You get the same `FramePull_<video name>/` layout as on the Mac (`stills/`, `gifs/`, `videos/`, `grids/`), and exporting the same video again continues the numbering instead of overwriting.

Options mirror the Mac: still format and size, clip quality and mute, GIFs, 4:5 and 9:16 crops, and grids. The screen stays awake while an export runs. **Cancel** stops after the item in progress.

**Not on iPhone and iPad yet:** LUTs and *Prefer faces* still placement are Mac-only.
