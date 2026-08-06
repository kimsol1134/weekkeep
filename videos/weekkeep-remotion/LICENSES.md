# Weekkeep Remotion submission video — licenses and provenance

This manifest records the local files used by the Remotion submission video. It is a
provenance record, not a grant of rights beyond the stated sources. The source
trees under `videos/weekkeep-shipaton/` and the capture under
`videos/weekkeep-remotion/capture/` were not modified.

## Weekkeep-owned product media

- `public/footage/weekkeep-remotion-ui.mp4` is a byte-for-byte copy of
  `videos/weekkeep-remotion/capture/raw/weekkeep-remotion-ui.mp4`, the actual
  English SwiftUI capture at 1320×2868. The edit trims away its simulator
  home-screen pre-roll and loading handoff; the curated edit first references
  source frame 360 (12.0 seconds at the Remotion timeline rate) and reuses
  functioning app footage in deliberate subclips. The raw/public copies are
  byte-identical.
- `public/brand/weekkeep-lockup.svg` is copied from
  `videos/weekkeep-shipaton/assets/weekkeep-lockup.svg`.
- `public/screenshots/07-settings.jpg` and
  `public/screenshots/09-paywall-price.jpg` are copied from the approved
  Shipaton assets. They are used only as short holds after the corresponding
  real footage needs to extend to the approved narration boundary.
- The seven-stitch palette in `src/tokens.ts` is exactly
  `#E97A68 #E39455 #E5A84B #66836E #5F879B #686286 #8A6386`, in order.

## Audio

- `public/audio/bgm/track.wav` is copied from the approved procedural BGM at
  `videos/weekkeep-shipaton/assets/bgm/track.wav`. The source manifest records
  it as Weekkeep-owned procedural FFmpeg output, 72.000 seconds, stereo,
  48 kHz, 16-bit PCM. The preview uses it at volume 0.11 under narration.
- `public/audio/voice/01.wav` through `10.wav` are copied from the approved
  narration at `videos/weekkeep-shipaton/assets/voice/`. Their exact approved
  durations are 6, 6, 11.5, 9, 7, 5, 6, 7, 10, and 4.5 seconds.
  `src/data/audio_meta.json` retains the approved generator and timing record.
- The narration is identified in the source manifest as Kokoro/Kokoro-82M,
  voice `af_heart`. The model is published under Apache-2.0 at
  https://huggingface.co/hexgrad/Kokoro-82M; model weights are not bundled.

## Fonts

- `public/fonts/LINE-Seed-Sans-KR-Regular.ttf` and
  `public/fonts/LINE-Seed-Sans-KR-Bold.ttf` are copied from the approved
  `LINE Seed Sans KR` files. They are loaded locally through `@remotion/fonts`.
- The SIL Open Font License 1.1 text is retained at
  `licenses/LINESeedKR-OFL.txt`.
- `licenses/JetBrainsMono-OFL.txt` is retained with the source manifest for
  provenance completeness; this Remotion composition does not use JetBrains
  Mono.

## Metadata

`src/data/audio_meta.json` is the approved narration and timing source.
`src/data/caption_groups.json` is derived, deterministically generated English
phrase grouping validated by `scripts/rebuild-captions.mjs` and
`scripts/validate-captions.mjs`. Captions are rendered as stable, readable
phrases; no word-bouncing or karaoke treatment is added.
