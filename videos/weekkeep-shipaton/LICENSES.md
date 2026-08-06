# Weekkeep Shipaton audio, font, and asset provenance

This manifest records the local files used by `videos/weekkeep-shipaton` and
the provenance/license evidence retained with the project. It is a provenance
record, not a grant of rights beyond the stated sources.

## Audio

### Original procedural BGM

`assets/bgm/track.wav` is Weekkeep-owned procedural output generated locally by
`scripts/generate-original-bgm.sh`. The script uses only FFmpeg `aevalsrc` and
`alimiter`; it imports no samples, makes no network request, and loads no ML
model. The release metadata records the mode as
`procedural_ffmpeg_original` in `bgm_status.json` and `audio_engine_meta.json`.

The expected artifact is a 72.000-second, stereo, 48 kHz, 16-bit PCM WAV with
SHA-256
`10d9340c16c3234826451c4a71808aa9125a91b67af04288df66bc9996f63ce0`.
`scripts/validate-provenance.sh` checks those values and that the generation
script is executable.

The legacy MusicGen logs and track are rejected material. The logs are retained
with their original names under
`release/local/rejected/video/musicgen-logs/`; the MusicGen WAV remains at
`release/local/rejected/video/musicgen-track.wav`. Neither is in the submission
asset tree or used by this video.

### Kokoro narration

`assets/voice/01.wav` through `assets/voice/10.wav` are generated narration
files. The local audio metadata records the generator as Kokoro/Kokoro-82M and
the voice as `af_heart` (`audio_engine_meta.json`, `audio_meta.json`). The
Kokoro-82M model is published under Apache-2.0 at
<https://huggingface.co/hexgrad/Kokoro-82M>; the model weights are not bundled
in this submission tree. This entry identifies the model and voice used to
generate the audio without claiming that the WAV files are model weights.

### Sound effects

These five files are from the bundled media-use SFX library. Its local
`CREDITS.md` records them as Pixabay assets used under the Pixabay Content
License:

- `assets/sfx/chime.mp3`
- `assets/sfx/click-soft.mp3`
- `assets/sfx/pop.mp3`
- `assets/sfx/sparkle.mp3`
- `assets/sfx/whoosh-short.mp3`

License terms: <https://pixabay.com/service/license-summary/>.

## Fonts

### LINE Seed Sans KR — SIL Open Font License 1.1

The HTML frames use the canonical files `assets/fonts/LINESeedKR-Rg.ttf` and
`assets/fonts/LINESeedKR-Bd.ttf`. The captions composition also uses the
byte-identical copies `assets/fonts/LINE Seed Sans KR-Regular.ttf` and
`assets/fonts/LINE Seed Sans KR-Bold.ttf`.

The bundled license is
`licenses/LINESeedKR-OFL.txt`. It is byte-for-byte sourced from
`Weekkeep/Resources/Licenses/LINESeedKR-OFL.txt`, and the local validator
checks that comparison. The source record identifies LINE Seed Sans KR as
LY Corporation / LINE VX Design, Sandoll Inc., and Dalton Maag Ltd.; see
`resources/fonts/line-seed-kr/SOURCE.md` and the bundled OFL text.

### JetBrains Mono — SIL Open Font License 1.1

The HTML frames use `assets/fonts/JetBrainsMono-Regular.woff2` for the mono
chrome. The byte-identical spaced-name copy is also retained under
`assets/fonts/JetBrains Mono-Regular.woff2`.

The official JetBrains Mono OFL 1.1 contract is bundled at
`licenses/JetBrainsMono-OFL.txt`, including the JetBrains Mono Project Authors
copyright notice. The upstream source is
<https://github.com/JetBrains/JetBrainsMono>.

## Weekkeep-owned fixtures

The product screenshots, app icon, lockup, and other product assets bundled
under this project are Weekkeep-owned deterministic fixtures used to compose
the submission video. Their provenance is separate from the third-party audio
and font entries above.
