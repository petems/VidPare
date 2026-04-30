## Cursor Cloud specific instructions

### Environment overview

This codebase has two products:

1. **VidPare macOS app** (Swift/SwiftUI) — requires macOS + Xcode. Cannot build or run on Linux. `swift build`, `swift test`, and the macOS-only acceptance tests will fail on Linux VMs due to missing SwiftUI/AVFoundation frameworks.
2. **Product website** (`site/`) — Astro + Tailwind static site. Fully functional on Linux with Node.js.

### What works on Linux Cloud VMs

| Tool | Status | Notes |
|---|---|---|
| `swiftlint` | Works | Lints all Swift source files successfully |
| `swift-format lint -r Sources/ Tests/` | Works | Checks formatting of Swift files |
| `swift package resolve` | Works | Resolves SPM dependencies |
| `swift build` | Fails | SwiftUI/AVFoundation not available on Linux |
| `swift test` | Fails | Tests depend on macOS frameworks |
| `cd site && npm run dev` | Works | Astro dev server on port 4321 |
| `cd site && npm run build` | Works | Production build (`astro check` + `astro build`) |

### Running the services

- **Website dev server**: `cd site && npm run dev` (port 4321). Add `-- --host 0.0.0.0` to bind to all interfaces.
- **Swift linting**: `swiftlint` from repo root (or `make lint`).
- **Swift format check**: `make format-check` from repo root.
- See `CLAUDE.md` for the full set of `make` targets and development commands.

### Gotchas

- The Swift toolchain (6.1) is installed at `/opt/swift/usr/` with binaries symlinked to `/usr/local/bin/`. The `libncurses6` package must be present for Swift to run.
- SwiftLint is installed at `/usr/local/bin/swiftlint` (v0.57.1 Linux binary from GitHub releases).
- `swift-format` in this toolchain reports version as `main` rather than a semver — this is normal for the bundled build.
- Pre-commit hooks reference `no-commit-to-branch` which blocks direct commits to `master`/`main`. Cloud agent branches (e.g. `cursor/*`) are unaffected.
- Snapshot tests and acceptance tests are macOS-only and cannot run in this environment.
