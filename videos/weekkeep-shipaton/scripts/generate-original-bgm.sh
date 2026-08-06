#!/bin/sh
set -eu

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "generate-original-bgm.sh: ffmpeg is required to synthesize the BGM." >&2
  exit 127
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
output_dir="$project_dir/assets/bgm"
output_path="$output_dir/track.wav"

duration_s=72
sample_rate=48000
channels=2

mkdir -p "$output_dir"
temp_path=$(mktemp "$output_dir/.track.wav.XXXXXX")
cleanup() {
  rm -f "$temp_path"
}
trap cleanup EXIT HUP INT TERM

# Every sound in this graph is synthesized by FFmpeg's expression source.
# There are no imported samples, network inputs, or ML/model dependencies.
# The four sustained tones form a quiet chord bed; the slow amplitude movement
# and the very soft three-second pulse keep it warm without carrying a melody.
filter_graph='aevalsrc=(0.76+0.12*sin(2*PI*0.035*t)+0.05*sin(2*PI*0.071*t+1.4))*(0.09*sin(2*PI*220*t)+0.06*sin(2*PI*277.18*t+0.3)+0.055*sin(2*PI*329.63*t+0.8)+0.035*sin(2*PI*415.30*t+1.2))+0.010*(0.5+0.5*cos(2*PI*t/3))*sin(2*PI*110*t)+0.006*sin(2*PI*440*t+0.2*sin(2*PI*0.08*t))|(0.76+0.12*sin(2*PI*0.035*t+0.45)+0.05*sin(2*PI*0.071*t+2.1))*(0.09*sin(2*PI*220.15*t+0.15)+0.06*sin(2*PI*277.00*t+0.65)+0.055*sin(2*PI*329.90*t+1.15)+0.035*sin(2*PI*415.65*t+1.55))+0.010*(0.5+0.5*cos(2*PI*t/3+0.12))*sin(2*PI*110.15*t+0.2)+0.006*sin(2*PI*440.35*t+0.2*sin(2*PI*0.08*t+0.3)):s=48000:d=72,alimiter=limit=0.70:attack=5:release=50:level=disabled'

ffmpeg \
  -hide_banner \
  -loglevel error \
  -nostdin \
  -y \
  -f lavfi \
  -i "$filter_graph" \
  -map 0:a:0 \
  -t "$duration_s" \
  -ar "$sample_rate" \
  -ac "$channels" \
  -c:a pcm_s16le \
  -map_metadata -1 \
  -fflags +bitexact \
  -flags:a +bitexact \
  -f wav \
  "$temp_path"

mv -f "$temp_path" "$output_path"
printf '%s\n' "Generated original procedural BGM: $output_path (${duration_s}.000s, ${sample_rate}Hz, stereo PCM WAV)"
