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
distinct calendar/photo/settings bottom-nav icons, resolving the build-6
below-fold CTA finding for local DEBUG fixture build 7 only. Native share/delivery,
purchase/restore, actual PhotoKit performance, physical functioning footage, and
external App Store/ASC lifecycle gates remain pending; no remote-build
replacement was performed or authorized.

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

- submitted remote ASC build 6 and its signed IPA verification remain labeled with the actual build; build 6 is still `WAITING_FOR_REVIEW` under manual release;
- local physical screenshot evidence now has separate, ignored build-6 and build-7 directories. Build 7 is screenshot-scope evidence only: the waiting surface makes no CTA claim, while the DEBUG ready surface resolves the build-6 below-fold CTA finding. Native share/delivery and external lifecycle gates remain pending;
- `project.yml` is the SSOT for the local next candidate `1.0.0 (build 7)`. The local archive `LOCAL_EVIDENCE_DIR/weekkeep-build7-ssot.qTqqz6/Weekkeep.xcarchive` and exported IPA `LOCAL_EVIDENCE_DIR/weekkeep-build7-preflight.8Is5cC/export/Weekkeep.ipa` were inspected successfully; IPA SHA-256 is `6d8b62a2d8d354debf777791cbc795ddde662c01bdb0da91f31640c101b8d2bf`. The inspection passed for `com.solkim.weekkeep`, version `1.0.0`, build `7`, minimum iOS `18.0`, iPhone-only, `ITSAppUsesNonExemptEncryption=false`, valid strict code signature using `Apple Distribution: sol kim` (team `D48DDX5D5W`, `Weekkeep App Store` profile), `get-task-allow=false`, `beta-reports-active=true`, app `PrivacyInfo`, and valid RevenueCat/PostHog manifests;
- at `2026-08-07 18:58 KST`, exact `asc xcode validate` on that IPA with the existing keychain ASC profile returned `VERIFY SUCCEEDED` with no errors and `validated=true`. This is Apple server-side IPA validation only: it did not upload, register build 7, attach it to a version, submit it for review, obtain approval, or release it. A subsequent read-only ASC builds list still contained only builds `1, 2, 3, 4, 6`; remote version `1.0.0` and its manual-release submission remain `WAITING_FOR_REVIEW` on build 6;
- build 7 contains the cumulative family week ordinal, conversational prompt/invitation, and privacy-safe `share_completed` improvements, but remains not uploaded, attached, submitted, live, or part of the current remote review submission;
- the unsubmitted next-candidate local share loop is kept separate from ASC build 6: it uses image-first native sharing plus the localized invitation and canonical Apple URL `https://apps.apple.com/app/id6798449478`; the URL is not claimed live before public release;
- the opt-in physical-iPhone native-share-sheet QA harness for local build 7 at `WeekkeepUITests/WeekkeepUITests/testPhysicalShareSheetQAIsOptInFixtureOnlyNoPrivatePixelsNoSend` was retried twice with the paired physical iPhone 16 Pro unlocked. Both runs installed/launched the runner but failed before executing the test body with `Timed out while enabling automation mode.` Read-only Mac-host diagnostics showed `xcrun automationmodetool: Automation Mode is disabled. This device requires user authentication to enable Automation Mode;` and `/usr/sbin/DevToolsSecurity -status: Developer mode is currently disabled.` This is a Mac host security/automation prerequisite, not an app failure or iPhone-lock blocker. The invalid/non-evidence result bundles are `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7-unlocked.lRcjSA/PhysicalShareQA.xcresult` and `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7-retry.8vH05v/PhysicalShareQA.xcresult`; the earlier locked attempt `LOCAL_EVIDENCE_DIR/weekkeep-physical-share-build7.p0FReh/PhysicalShareQA.xcresult` is historical context only, not the current blocker. No test body executed, no valid attachments/screenshots were produced, no share destination was selected, no send occurred, no private PhotoKit access occurred, and no purchase/restore occurred; physical QA remains pending;
- TestFlight internal QA distribution records build 6 as `READY_FOR_BETA_TESTING` with one invited verified account-holder tester; installation, purchase, and restore testing remain unverified;
- historical build-3/build-5 App Store evidence remains separate from the build-6 Settings visual-QA evidence;
- root LICENSE is present and locally validated as MIT for Sol Kim;
- public repository URL, source availability, and logged-out verification are
  recorded as validated for `https://github.com/kimsol1134/weekkeep`;
- no secrets, private reviewer contact values, judge codes, or local evidence
  enter the public-source candidate.
