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

Deterministic fixture screenshots are captured as XCTest attachments, never
from real family photos:

```sh
scripts/capture-fixture-screenshots.sh /private/tmp/weekkeep-fixture-capture
```

The output is local evidence. It is not an App Store submission until the
actual device dimensions, localization, alpha, and reviewer-approved assets
have been manually checked.

The local Shipaton demo render is tracked separately in
`videos/weekkeep-remotion/out/weekkeep-shipaton-72.mp4`; its 72-second MP4 and
current-source QA are locally validated. Public video upload, logged-out
playback, and target-device evidence remain external release gates.

When a managed XcodeBuildMCP run already produced an `.xcresult`, set
`WK_FIXTURE_RESULT_BUNDLE` to export the same four attachments without asking
the shell to start a second simulator build.

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

- local candidate build and screenshots are labeled with the actual build;
- historical build-5 six-screen App Store evidence remains separate from the build-6 Settings visual-QA evidence;
- root LICENSE is present and locally validated as MIT for Sol Kim;
- public repository URL, source availability, and logged-out verification are
  recorded as validated for `https://github.com/kimsol1134/weekkeep`;
- no secrets, private reviewer contact values, judge codes, or local evidence
  enter the public-source candidate.
