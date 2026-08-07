# Screenshot evidence boundary

The build-7 fixture capture script exports raw, device-frame-free XCTest
attachments as deterministic name anchors and, while each state is held,
captures the exact simulator framebuffer as an opaque JPEG. XCTest attachments
can differ from the simulator framebuffer by a pixel on some iOS/Xcode
versions, so the selected Shipaton pixels come from the same-state simulator
captures rather than a resized XCTest attachment.

The App Store 6.9-inch set is a separate deterministic bundled-fixture UI
capture. Its DEBUG launch mode uses `-ui-app-store-fixtures`,
`FixturePhotoLibraryClient`, and the bundled `SamplePhotoFixtures`; it does not
import media into Simulator Photos or exercise PhotoKit. Real PhotoKit behavior
is validated separately through the live adapter/device QA path.

The captured Plus screen is a native item-driven full-screen surface. It must
not be presented inside a gray sheet, nested rounded sheet, bezel, or device
frame. Explanatory onboarding, Ready, and Plus surfaces share the flat
`FixturePhotoStory` hero+2+4 photo vocabulary and the approved seven fictional
fixture PNGs; those fixtures are not user content.

Capture the selected build-7 submission proof from an iPhone 15 Pro simulator
framebuffer as JPEG, using the four canonical milestone names below. Then
validate the set:

```sh
scripts/validate-submission-screenshots.sh /absolute/path/to/screenshots
```

The default validator requires exactly four files — `01-welcome.jpg`,
`02-review.jpg`, `03-save-confirmation.jpg`, and `04-share-preview.jpg` — each
exactly `1179×2556`, opaque, and sRGB/RGB JPEG. The fourth frame is the real
in-app Story/Post preview; the Apple native share sheet is not opened. The
older `03-review-selected.jpg`/`04-save-confirmation.jpg` contract remains
available only through `--legacy` for historical video evidence. These are
fixture-only local submission candidates, not a claim that App Store,
Shipaton, ASC, or Devpost assets have been approved or uploaded; proof must
also omit device frames and marketing headline overlays.

Only approved fixture artwork may be used. The same approved synthetic PNGs
may also appear in the bundled static onboarding preview; they are never user
content. Do not place private family photos, promo codes, or screenshots
containing account state in the repository.
