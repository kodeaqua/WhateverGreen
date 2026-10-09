# WhateverGreen

Lilu plugin (macOS kext, C++) that patches Apple graphics drivers: AMD Radeon (`kern_rad`), Intel iGPU (`kern_igfx*`), NVIDIA (`kern_ngfx`, `kern_nvhda`), Shiki/DRM (`kern_shiki`), plus board/model and AGDC fixes. Kernel code — no hardware-free runtime tests; correctness is verified by building, the clang analyzer and careful review.

## Build

Needs sibling checkouts of Lilu and MacKernelSDK (both are gitignored here):

```sh
ln -s ../MacKernelSDK MacKernelSDK      # or clone acidanthera/MacKernelSDK
cp -R ../Lilu/build/Debug/Lilu.kext .   # a built Lilu.kext (Debug for Debug, Release for Release)
xcodebuild -jobs 4 -configuration Debug   # also: Release
xcodebuild analyze -quiet -scheme WhateverGreen -configuration Debug CLANG_ANALYZER_OUTPUT=plist-html CLANG_ANALYZER_OUTPUT_DIR="$TMPDIR/an"
```

CI (`.github/workflows/main.yml`) builds Debug+Release and fails if the analyzer produces any HTML report — keep it at zero.

## Layout

- `WhateverGreen/` — kext sources. `kern_start.cpp` is the entry; `kern_weg.cpp` is the shared core that dispatches to `RAD`, `IGFX`, `NGFX`, `SHIKI`, etc.
- `WhateverGreen/kern_igfx_*.cpp` — Intel features split per topic (backlight, clock, lspcon, memory, pm, i2c_aux, debug). `kern_igfx.hpp` is the big shared header.
- `kern_guc.cpp` — embedded GuC firmware blobs (data, ~18k lines; don't hand-edit).
- `Resources/Patches.plist` → `ResourceConverter` generates `kern_resources.cpp/.hpp` at build time (gitignored).
- `Manual/` — user-facing FAQs (several languages) and helper scripts; `Tools/` — small macOS C/ObjC helpers (`build.tool` per tool); `Prebuilt/` — committed binaries of those tools.

## Conventions

- Logging: `DBGLOG`/`SYSLOG("module", fmt, ...)`. Format specifiers must match arguments — cast pointers and `IOReturn` to `unsigned long long` for `%llx`, and print unions like `ConnectorFlags` via `.value`. The build treats mismatches as warnings, so check them.
- Patches are routed with `KernelPatcher::routeMultiple`/`routeMultipleLong`; `routeFunction` is deprecated but still used in a few places.
- Keep the kext deployment target at 10.6 and code in the existing C++ subset (no exceptions/RTTI).
- Hardware-dependent offsets and framebuffer structs are reverse-engineered; don't "clean up" them without a reason and a way to verify.
- Update `Changelog.md` for user-visible changes. Version bumps are separate commits ("Bump version").

## Commits

Conventional style in English: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`; one logical change per commit.
