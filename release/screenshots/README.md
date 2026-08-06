# Screenshot evidence boundary

The fixture capture script produces raw, device-frame-free XCTest screenshots
for functional visual review. XCTest attachments can differ from the simulator
framebuffer by a pixel on some iOS/Xcode versions, so they do not claim App
Store or Shipaton dimension compliance by themselves.

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

Capture the submission proof from an iPhone 15 Pro/14 Pro simulator framebuffer
as JPEG, using the four canonical milestone names below. Then validate the set:

```sh
scripts/validate-submission-screenshots.sh /absolute/path/to/screenshots
```

The validator requires exactly four files — `01-welcome.jpg`, `02-review.jpg`,
`03-review-selected.jpg`, and `04-save-confirmation.jpg` — each exactly
`1179×2556` with no alpha channel. The local Korean and English fixture sets
have passed this contract. They are functional submission evidence, not a claim
that final App Store marketing artwork has been approved or uploaded; Shipaton
proof must also omit device frames and marketing headline overlays.

Only approved fixture artwork may be used. The same approved synthetic PNGs
may also appear in the bundled static onboarding preview; they are never user
content. Do not place private family photos, promo codes, or screenshots
containing account state in the repository.
