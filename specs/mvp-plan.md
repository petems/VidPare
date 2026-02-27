# Plan: Implement MVP Video Trimmer (macOS, Swift + AVFoundation)

## Context

Building "VidPare," a native macOS video trimmer to escape the limitations of web-based tools (file size caps, no direct filesystem access, slow WASM-based processing). The repo is fresh — empty README on branch `claude/macos-video-trimmer-HsZP4`. AVFoundation provides hardware-accelerated passthrough remux (near-instant, lossless trim without re-encoding), which is the core value proposition.

## Key Decisions (Finalized)

| Decision | Choice | Rationale |
|---|---|---|
| Platform | Native macOS (Swift + SwiftUI + AVFoundation) | Hardware-accelerated, no dependencies |
| Build system | Swift Package (`Package.swift`) | Can be created via CLI, opens natively in Xcode, supports signing/entitlements when opened as Xcode project |
| macOS target | macOS 14 (Sonoma) | Enables `@Observable` macro and latest SwiftUI APIs |
| File size limit | **None** | AVFoundation streams data; memory usage doesn't scale with file size |
| Supported input formats | MP4, MOV, M4V only | These are what AVFoundation reliably handles. No MKV/AVI/WebM — those need ffmpeg (roadmap) |
| Video player | `AVPlayer` + `AVPlayerLayer` in `NSViewRepresentable` | Skip SwiftUI's `VideoPlayer` — need direct `seek(to:toleranceBefore:toleranceAfter:)` for precise scrubbing |
| Default export | Passthrough (remux) | Near-instant, lossless. Communicate keyframe-snapping tradeoff in UI |
| Distribution | Local dev signing for MVP | Notarized DMG deferred until broader distribution is needed |

## MVP Feature Set

- **Open file**: Drag-and-drop or file picker. MP4, MOV, M4V.
- **Preview**: Inline video playback with scrubbing via AVPlayer
- **Timeline**: Thumbnail strip (via `AVAssetImageGenerator`) with draggable in/out trim handles
- **Trim**: Single cut — set in-point and out-point
- **Export formats**: MP4 (H.264), MOV (H.264), MP4 (HEVC/H.265)
- **Quality presets**: Passthrough (fastest, default), High, Medium, Low
  - Note: Passthrough preserves the source codec; if the user selects HEVC format, quality auto-promotes from Passthrough to High unless the source is already HEVC. Selecting Passthrough disables the format picker since format is determined by the source codec.
- **Estimated output size** shown in export dialog
- **Export location**: User-chosen via save dialog

**Excluded from MVP**: Multi-cut, audio-only export, filters/effects, batch processing, format conversion as standalone feature.

## Project Structure

```text
vidpare/
├── Package.swift                          # Swift Package manifest (macOS 14+, SwiftUI lifecycle)
├── Sources/
│   └── VidPare/
│       ├── App/
│       │   └── VidPareApp.swift              # @main entry point, WindowGroup
│       ├── Models/
│       │   ├── VideoDocument.swift           # AVAsset wrapper, file metadata
│       │   └── TrimState.swift              # In/out points, export settings (@Observable)
│       ├── Views/
│       │   ├── ContentView.swift            # Main window layout (player + timeline + controls)
│       │   ├── VideoPlayerView.swift        # NSViewRepresentable wrapping AVPlayerLayer
│       │   ├── TimelineView.swift           # Thumbnail strip + draggable trim handles
│       │   ├── PlayerControlsView.swift     # Play/pause, time display, trim buttons
│       │   └── ExportSheet.swift            # Format picker, quality presets, estimated size, save
│       ├── Services/
│       │   ├── VideoEngine.swift            # Trim/export via AVAssetExportSession
│       │   └── ThumbnailGenerator.swift     # AVAssetImageGenerator wrapper for timeline thumbnails
│       └── Utilities/
│           └── TimeFormatter.swift          # Duration/timestamp formatting helpers
├── Tests/
│   └── VidPareTests/
│       └── VideoEngineTests.swift
├── .gitignore
└── README.md
```

## Implementation Steps

### Step 1: Project Setup
- Create `Package.swift` with macOS 14+ platform target, SwiftUI lifecycle
- Set up `Sources/VidPare/` and `Tests/VidPareTests/` directory structure
- Configure app bundle identifier, signing (local dev) when opening in Xcode
- Add .gitignore for Xcode/Swift projects
- Commit initial project skeleton

### Step 2: Video Loading
- File picker (`fileImporter` modifier) accepting `.mp4`, `.mov`, `.m4v` UTTypes
- Drag-and-drop support on the main window (`onDrop`)
- `VideoDocument` model: wraps `AVURLAsset`, exposes duration, resolution, codec info, file size
- Validate file can be loaded by AVFoundation; show error for unsupported files
- **Key API**: `AVURLAsset(url:options:)`, `asset.loadTracks(withMediaType:)`

### Step 3: Video Playback
- `VideoPlayerView`: `NSViewRepresentable` hosting `AVPlayerLayer`
- Wire `AVPlayer` to the loaded `AVPlayerItem`
- `addPeriodicTimeObserver` for syncing playback position to timeline
- Play/pause toggle, seek to arbitrary time
- Playback clamps at trim endTime and loops back to startTime via the periodic time observer
- **Key API**: `AVPlayer`, `AVPlayerLayer`, `seek(to:toleranceBefore:toleranceAfter:)`

### Step 4: Timeline with Thumbnails
- `ThumbnailGenerator` service: uses `AVAssetImageGenerator` to extract frames at regular intervals
- Generate thumbnails proportional to video duration (e.g., ~1 per 2 seconds for short clips, clamped to a min of 10 and max of 60 for longer videos)
- `TimelineView`: horizontal strip of thumbnail images
- Draggable in-point and out-point handles (SwiftUI `DragGesture`)
- Visual indication of selected trim region (highlighted area between handles)
- Playhead indicator synced to `AVPlayer` position
- Tapping on timeline seeks player to that position
- **Key API**: `AVAssetImageGenerator.generateCGImagesAsynchronously(forTimes:completionHandler:)`

### Step 5: Trim & Export Engine
- `VideoEngine.export()` method with these modes:
  - **Export modes:** Quality preset is the primary selector. When **Passthrough** is selected, the format picker is disabled — the output preserves the source codec and container. When any re-encode preset (High, Medium, Low) is selected, the format picker is enabled, allowing the user to choose H.264 or HEVC output. If the user selects HEVC format while quality is set to Passthrough, the quality auto-promotes to High (unless the source codec is already HEVC, in which case Passthrough is kept).
- Output file type mapping: `.mp4` -> `AVFileType.mp4`, `.mov` -> `AVFileType.mov`
- Progress tracking via `exportSession.progress` (polled on timer)
- Cancellation support via `exportSession.cancelExport()`
- Estimated output size calculation:
  - Passthrough: `(trimDuration / totalDuration) * fileSize`
  - Re-encode: estimate from target bitrate * duration
- **Key API**: `AVAssetExportSession`, `CMTimeRange(start:end:)` or `CMTimeRange(start:duration:)`

### Step 6: Export UI
- `ExportSheet` presented as a sheet/modal
- Format picker: MP4 (H.264), MOV (H.264), MP4 (HEVC)
- Quality picker: Passthrough (default), High, Medium, Low
- Display estimated output size
- Note in UI: "Passthrough trim snaps to nearest keyframe" vs "Precise trim re-encodes (slower)"
- `NSSavePanel` for choosing output location
- Progress bar during export with cancel button

### Step 7: Polish
- Keyboard shortcuts: Space (play/pause), I (set in-point), O (set out-point), Cmd+E (export)
- Window title: filename + trim duration
- Error handling: unsupported file format, export failure, disk full, file system permission errors (especially with App Sandbox)
- Menu bar: File > Open, Edit > Trim shortcuts
- App icon (can use a simple placeholder for MVP)

## Verification

- Open MP4, MOV, M4V files via drag-and-drop and file picker
- Scrub through video using timeline; verify thumbnail strip renders correctly
- Set in/out trim points; verify playback respects trim boundaries and loops within the selected region
- Export with passthrough preset; verify output plays correctly and export completes fast
- Export with re-encode (H.264 High); verify output plays and is smaller than source
- Export as HEVC; verify output plays in QuickTime
- Test with various file sizes (small 10MB clips, large 2GB+ files)
- Test with H.264 and HEVC source files
- Attempt to open .mkv or .avi — verify clear error message
- Start an export, try opening a new file — verify it is blocked with error message
- Verify estimated output size is shown and roughly accurate after export

## Important Technical Notes

- Use `@Observable` (macOS 14+) instead of `ObservableObject` for state management
- `AVAssetImageGenerator` should use `appliesPreferredTrackTransform = true` to handle rotated videos
- For passthrough export, trim points snap to keyframes — the UI should communicate this clearly
- HEVC encoding is significantly slower than H.264 even with hardware acceleration — worth noting in UI
- `AVAssetExportSession.progress` can be unreliable; poll at ~0.5s intervals and handle non-monotonic values
- Security-scoped resource access is reference-counted on macOS. Blocking file loading during active exports is the primary protection against concurrent access. As a defensive secondary safeguard, the export method retains an extra security-scope reference to the source URL for the duration of the operation, preventing permission loss if the source file is moved/renamed during export or if other operations attempt to release the scope.
- The project uses a `Package.swift`-based layout. Open the package directory in Xcode (`File > Open...` on the repo root) to get full Xcode integration including signing, entitlements, and asset catalog support. Alternatively, build from CLI with `swift build`.
