#!/usr/bin/env node

import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const PROJECT_ROOT = fileURLToPath(new URL("..", import.meta.url));
const AUDIO_META_PATH = join(PROJECT_ROOT, "src/data/audio_meta.json");
const CAPTION_GROUPS_PATH = join(PROJECT_ROOT, "src/data/caption_groups.json");

// Editorial boundaries. The words and all timings are always read from
// audio_meta.json; these counts only decide where a readable phrase ends.
const GROUP_SIZES = [
  [9, 9], // Two complete opening sentences.
  [6, 8], // Camera roll into the fixed phrase "up to seven".
  [8, 6, 7], // Access, on-device processing, and the upload boundary.
  [5, 7, 7, 3], // Draft, limit, fewer photos, and the result.
  [5, 8, 4], // Parent as editor, then the replacement instruction.
  [8], // One-tap local save.
  [6, 6], // Revisit without streaks, backlog, or an account.
  [6, 8], // Optional reminder and visible privacy boundary.
  [4, 8, 5], // Free allowance, lifetime purchase, and no subscription.
  [5], // Closing line keeps "a week worth keeping" together.
];

const HOLD_SECONDS = 0.18;
const FINAL_HOLD_SECONDS = 0.28;

const roundSeconds = (seconds) => Math.round(seconds * 100) / 100;
const readJson = (path) => JSON.parse(readFileSync(path, "utf8"));

const buildCaptionGroups = (audioMeta) => {
  const groups = [];
  let segmentOffset = 0;
  let groupIndex = 0;

  if (GROUP_SIZES.length !== audioMeta.voices.length) {
    throw new Error("GROUP_SIZES must define boundaries for every voice segment.");
  }

  for (let voiceIndex = 0; voiceIndex < audioMeta.voices.length; voiceIndex += 1) {
    const voice = audioMeta.voices[voiceIndex];
    let wordCursor = 0;

    for (const groupSize of GROUP_SIZES[voiceIndex]) {
      const sourceWords = voice.words.slice(wordCursor, wordCursor + groupSize);

      if (sourceWords.length !== groupSize) {
        throw new Error(
          `Voice ${voice.frame} does not have ${groupSize} words at cursor ${wordCursor}.`,
        );
      }

      const nextWord = voice.words[wordCursor + groupSize];
      const lastWord = sourceWords[sourceWords.length - 1];
      const nextBoundary = nextWord
        ? segmentOffset + nextWord.start
        : segmentOffset + voice.duration_s;
      const hold = nextWord ? HOLD_SECONDS : FINAL_HOLD_SECONDS;
      const end = Math.min(
        nextBoundary,
        segmentOffset + lastWord.end + hold,
      );

      groups.push({
        id: `caption-group-${groupIndex}`,
        frame: voice.frame,
        start: roundSeconds(segmentOffset + sourceWords[0].start),
        end: roundSeconds(end),
        text: sourceWords.map((word) => word.text).join(" "),
        words: sourceWords.map((word, localIndex) => ({
          id: `caption-word-${groupIndex}-${localIndex}`,
          text: word.text,
          start: roundSeconds(segmentOffset + word.start),
          end: roundSeconds(segmentOffset + word.end),
        })),
      });

      wordCursor += groupSize;
      groupIndex += 1;
    }

    if (wordCursor !== voice.words.length) {
      throw new Error(
        `Voice ${voice.frame} has ${voice.words.length - wordCursor} ungrouped words.`,
      );
    }

    segmentOffset += voice.duration_s;
  }

  return {
    total_duration_s: audioMeta.bgm.duration_s,
    width: 1920,
    height: 1080,
    groups,
  };
};

const audioMeta = readJson(AUDIO_META_PATH);
const generated = buildCaptionGroups(audioMeta);
const serialized = `${JSON.stringify(generated, null, 2)}\n`;
const mode = process.argv[2];

if (mode === "--write") {
  writeFileSync(CAPTION_GROUPS_PATH, serialized);
  console.log(`Rebuilt ${generated.groups.length} caption groups from audio_meta.json.`);
} else if (mode === "--verify") {
  const committed = readJson(CAPTION_GROUPS_PATH);
  if (JSON.stringify(committed) !== JSON.stringify(generated)) {
    console.error(
      "caption_groups.json is out of date. Run npm run captions:rebuild and review the diff.",
    );
    process.exitCode = 1;
  } else {
    console.log(
      `Caption regeneration verified: ${generated.groups.length} groups match audio_meta.json.`,
    );
  }
} else {
  process.stdout.write(serialized);
}
