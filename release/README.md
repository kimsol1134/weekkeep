# Weekkeep release package

The tracked files in this directory are machine-readable release inputs and
contracts. The narrative sources remain the SSOT in `docs/09`–`docs/11`; the
validator checks that the app, product, privacy, and screenshot contracts do
not drift before an archive is attempted.

Run the repository gate from the project root:

```sh
scripts/validate-release.sh
```

Use `--strict` only after the authenticated RevenueCat/App Store configuration
and release key injection are available. The default mode is deliberately
useful before credentials exist: it passes safe repository checks and reports
external blockers without accepting a falsely configured production build.

The selected build-7 Shipaton screenshot candidate is captured as XCTest
attachments, never from real family photos:

```sh
scripts/capture-build7-shipaton-screenshots.sh \
  /absolute/path/to/release/local/visual-qa/20260807-build7-shipaton-sharing-v12
```

The script refuses overwrite, requires a booted iPhone 15 Pro on iOS 26.5,
coordinates same-state `simctl` JPEG framebuffer captures with the opt-in
XCTest test, maps the four XCTest attachments by exact attachment name,
rejects extra images, wrong dimensions, and alpha, and writes opaque sRGB
JPEGs to `final/` without changing geometry. Raw XCTest attachments, exact
simulator captures, the result bundle, provenance, and checksums remain in
the parent evidence directory. The output is explicitly fixture-only local
evidence; it is not App Store, Devpost, production PhotoKit, or ASC evidence.

The older four-milestone capture remains available only for historical video
references:

```sh
scripts/capture-fixture-screenshots.sh LOCAL_EVIDENCE_DIR/weekkeep-legacy-capture
scripts/validate-submission-screenshots.sh --legacy /absolute/path/to/legacy/final
```

The approved Shipaton demo render is tracked separately in
`videos/weekkeep-remotion/out/weekkeep-shipaton-72.mp4`; its 72-second MP4 and
current-source QA are validated and unchanged. A GitHub Release backup is
available at `https://github.com/kimsol1134/weekkeep/releases/tag/shipaton-demo-v1`
with direct asset
`https://github.com/kimsol1134/weekkeep/releases/download/shipaton-demo-v1/weekkeep-shipaton-72.mp4`
(both HTTP 200). The official public YouTube gate is validated at
`https://youtu.be/WJP6xoWV440`; logged-out playback and duration verification
are recorded in the manifest and [Shipaton Submission SSOT](../docs/11-SHIPATON-SUBMISSION.md#7-72-second-demo-master).
Target-device functioning footage remains a separate pending release gate.
The backup asset digest is
`9d4afb5332d3bbaeb0fc40e5d1d71c6a66b7cf2d72b79ed8a7ab3c2864e5a01a`, matching the
protected approved MP4.

The physical-device screenshot evidence is kept in two MECE local directories.
The historical build-6 DEBUG fixture evidence remains at
`release/local/target-device-qa/20260807T2006KST-build6-debug-fixture-device-screenshots/`;
its ready capture records the primary start CTA below the initial viewport.
The new local build-7 evidence is at
`release/local/target-device-qa/20260807T2033KST-build7-physical-screenshots/`.
It contains the local archive waiting surface and the signed DEBUG fixture ready
surface from a physical iPhone 16 Pro, each an opaque `1206×2622` PNG with exact
source/destination hashes and provenance in `QA-SUMMARY.md`. The DEBUG ready
capture places `지난주 추억 고르기` fully in the initial viewport and shows
distinct calendar/photo/settings bottom-nav icons, resolving the historical build-6
below-fold CTA finding for local DEBUG fixture build 7 only. The canonical ASC
replacement is now build 7; native share/delivery, purchase/restore, actual
PhotoKit performance, physical functioning footage, App Review approval, and
public App Store release remain pending.

Build-7 capture does not support `WK_FIXTURE_RESULT_BUNDLE`. The script rejects
that variable because exact same-state `simctl` framebuffer captures require a
fresh marker-coordinated XCTest run. Run the script without the variable so
the XCTest capture and simulator framebuffer capture are coordinated in the
same run; a prior `.xcresult` cannot be reused for this flow.

After RevenueCat configuration is authenticated and injected locally, create a
non-uploading archive with:

```sh
scripts/archive-release.sh /private/tmp/weekkeep-release-archive
```

The script deliberately stops at a local `.xcarchive`; export and store
submission remain human-controlled steps.

The local public-source gate is also part of release validation. It checks the
root MIT license, ignored secret/evidence paths, and redacted candidate-source
scans. The canonical public repository URL and logged-out source verification
are validated in the manifest from the supplied external evidence; App Store,
purchase, video, judge, and submission gates remain separate.

Run the focused gate from the project root:

    scripts/validate-public-source.sh

Release checklist:

- submitted remote ASC build 7 (`1c51b451-d37f-4704-89c9-e426b1ee5725`) and its canonical IPA verification remain current; build 7 is `VALID`, attached, and `WAITING_FOR_REVIEW` under manual release. Previous submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is historical `COMPLETE`, and build 6 is historical/replaced;
- local physical screenshot evidence now has separate, ignored build-6 and build-7 directories. Build 7 remains screenshot-scope/fixture evidence only: the waiting surface makes no CTA claim, while the DEBUG ready surface resolves the historical build-6 below-fold CTA finding. Native share/delivery and external lifecycle gates remain pending;
- canonical release IPA evidence is 23,420,062 bytes with SHA-256 `25c2c1ff17b14bd976392f3d8d6d1c103bd5488de66b866cadb8a5339f627889`; Apple server-side validation succeeded with no errors before upload, and the remote build is now attached/submitted;
- build 7 contains the cumulative family week ordinal, conversational prompt/invitation, and privacy-safe `share_completed` improvements; its local share/fixture evidence is kept separate from production PhotoKit and native share delivery;
- the build-7 local share loop uses image-first native sharing plus the localized invitation and canonical Apple URL `https://apps.apple.com/app/id6798449478`; the URL is not claimed publicly live before App Review approval and manual release;
- the opt-in physical-iPhone native-share-sheet QA harness for local build 7 at `WeekkeepUITests/WeekkeepUITests/testPhysicalShareSheetQAIsOptInFixtureOnlyNoPrivatePixelsNoSend` was retried twice with the paired physical iPhone 16 Pro unlocked. Both runs installed/launched the runner but failed before executing the test body with `Timed out while enabling automation mode.` Read-only Mac-host diagnostics showed `xcrun automationmodetool: Automation Mode is disabled. This device requires user authentication to enable Automation Mode;` and `/usr/sbin/DevToolsSecurity -status: Developer mode is currently disabled.` This is a Mac host security/automation prerequisite, not an app failure or iPhone-lock blocker. The invalid/non-evidence result bundles are `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7-unlocked.lRcjSA/PhysicalShareQA.xcresult` and `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7-retry.8vH05v/PhysicalShareQA.xcresult`; the earlier locked attempt `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7.p0FReh/PhysicalShareQA.xcresult` is historical context only, not the current blocker. No test body executed, no valid attachments/screenshots were produced, no share destination was selected, no send occurred, no private PhotoKit access occurred, and no purchase/restore occurred; physical QA remains pending;
- TestFlight internal QA distribution records historical build 6 as `READY_FOR_BETA_TESTING` with one invited verified account-holder tester; installation, purchase, and restore testing remain unverified;
- historical build-3/build-5 App Store evidence remains separate from historical build-6 Settings visual-QA evidence and the current build-7 release lifecycle;
- full Xcode test result is 174 passed, 0 failed, 4 skipped (178 total); public Sites version 5 site tests are 8 passed, 0 failed;
- root LICENSE is present and locally validated as MIT for Sol Kim;
- public repository URL, source availability, and logged-out verification are
  recorded as validated for `https://github.com/kimsol1134/weekkeep`;
- no secrets, private reviewer contact values, judge codes, or local evidence
  enter the public-source candidate.
