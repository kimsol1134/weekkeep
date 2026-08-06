#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const PROJECT_ROOT = fileURLToPath(new URL("..", import.meta.url));
const AUDIO_META_PATH = join(PROJECT_ROOT, "src/data/audio_meta.json");
const CAPTION_GROUPS_PATH = join(PROJECT_ROOT, "src/data/caption_groups.json");

const FPS = 30;
const EXPECTED_FRAMES = 2160;
const EXPECTED_DURATION_S = 72;
const EXPECTED_WIDTH = 1920;
const EXPECTED_HEIGHT = 1080;
const EPSILON = 0.001;
const MAX_HOLD_S = 0.31;
const MIN_GROUP_WORDS = 3;
const MAX_GROUP_WORDS = 10;

const FUNCTION_WORDS = new Set([
  "a",
  "an",
  "and",
  "are",
  "as",
  "at",
  "by",
  "for",
  "from",
  "if",
  "in",
  "into",
  "is",
  "of",
  "on",
  "or",
  "the",
  "to",
  "with",
]);

const FIXED_PHRASES = [
  "up to seven",
  "on the iphone",
  "one-time lifetime purchase",
  "a week worth keeping",
];

const readJson = (path) => JSON.parse(readFileSync(path, "utf8"));
const isClose = (left, right) => Math.abs(left - right) <= EPSILON;
const normalizeToken = (token) =>
  token.toLowerCase().replace(/[^a-z0-9-]/g, "");
const normalizeWords = (words) => words.map(normalizeToken);

const containsSequence = (tokens, phrase) => {
  const phraseTokens = phrase.split(" ").map(normalizeToken);
  for (let index = 0; index <= tokens.length - phraseTokens.length; index += 1) {
    if (phraseTokens.every((token, phraseIndex) => tokens[index + phraseIndex] === token)) {
      return true;
    }
  }
  return false;
};

const audioMeta = readJson(AUDIO_META_PATH);
const captionData = readJson(CAPTION_GROUPS_PATH);
const errors = [];
const fail = (message) => errors.push(message);

if (captionData.total_duration_s !== EXPECTED_DURATION_S) {
  fail(`Caption metadata duration must be ${EXPECTED_DURATION_S}s.`);
}
if (
  Math.round(captionData.total_duration_s * FPS) !== EXPECTED_FRAMES
) {
  fail("Caption metadata must resolve to exactly 2160 frames at 30fps.");
}
if (captionData.width !== EXPECTED_WIDTH || captionData.height !== EXPECTED_HEIGHT) {
  fail("Caption metadata must remain 1920x1080.");
}
if (audioMeta.bgm.duration_s !== EXPECTED_DURATION_S) {
  fail("BGM metadata must remain 72 seconds.");
}

const voiceOffsets = [];
let totalVoiceDuration = 0;
for (const [voiceIndex, voice] of audioMeta.voices.entries()) {
  voiceOffsets.push(totalVoiceDuration);
  if (voice.frame !== voiceIndex + 1) {
    fail(`Voice ${voiceIndex + 1} frame marker is not sequential.`);
  }
  totalVoiceDuration += voice.duration_s;
}
if (!isClose(totalVoiceDuration, EXPECTED_DURATION_S)) {
  fail(`Voice segments total ${totalVoiceDuration}s, expected ${EXPECTED_DURATION_S}s.`);
}

const groups = captionData.groups;
if (!Array.isArray(groups) || groups.length === 0) {
  fail("Caption metadata must contain at least one group.");
}

let previousEnd = 0;
let previousGroup = null;
const wordCursors = new Map();
const groupsByVoice = new Map();
let preferredSizeCount = 0;

for (const [groupIndex, group] of groups.entries()) {
  if (previousGroup && group.start + EPSILON < previousEnd) {
    fail(
      `${group.id ?? `group ${groupIndex}`} overlaps ${previousGroup.id ?? "the previous group"}.`,
    );
  }
  if (!Number.isFinite(group.start) || !Number.isFinite(group.end)) {
    fail(`${group.id ?? `group ${groupIndex}`} has non-numeric timing.`);
    continue;
  }
  if (group.start < -EPSILON || group.end > EXPECTED_DURATION_S + EPSILON) {
    fail(`${group.id ?? `group ${groupIndex}`} falls outside the 0–72s bounds.`);
  }
  if (group.start >= group.end) {
    fail(`${group.id ?? `group ${groupIndex}`} must have positive duration.`);
  }

  const words = group.words;
  if (!Array.isArray(words)) {
    fail(`${group.id ?? `group ${groupIndex}`} has no word list.`);
    continue;
  }
  if (words.length < MIN_GROUP_WORDS || words.length > MAX_GROUP_WORDS) {
    fail(
      `${group.id ?? `group ${groupIndex}`} has ${words.length} words; expected ${MIN_GROUP_WORDS}–${MAX_GROUP_WORDS}.`,
    );
  }
  if (words.length >= 3 && words.length <= 8) {
    preferredSizeCount += 1;
  }
  if (group.text !== words.map((word) => word.text).join(" ")) {
    fail(`${group.id ?? `group ${groupIndex}`} text is not verbatim from its words.`);
  }
  if (group.text.trim() !== group.text || /\s{2,}/.test(group.text)) {
    fail(`${group.id ?? `group ${groupIndex}`} contains unstable whitespace.`);
  }

  const firstToken = normalizeToken(words[0]?.text ?? "");
  const lastToken = normalizeToken(words[words.length - 1]?.text ?? "");
  const normalizedText = normalizeWords(words.map((word) => word.text)).join(" ");
  if (
    words.length < MIN_GROUP_WORDS ||
    (words.length < 4 &&
      (FUNCTION_WORDS.has(firstToken) || FUNCTION_WORDS.has(lastToken)))
  ) {
    fail(`${group.id ?? `group ${groupIndex}`} leaves an orphan function-word boundary.`);
  }
  if (normalizedText === "into up" || normalizedText === "to seven") {
    fail(`${group.id ?? `group ${groupIndex}`} contains a broken fixed phrase.`);
  }

  const voiceIndex = group.frame - 1;
  const voice = audioMeta.voices[voiceIndex];
  if (!voice) {
    fail(`${group.id ?? `group ${groupIndex}`} references voice frame ${group.frame}.`);
    continue;
  }

  const cursor = wordCursors.get(voiceIndex) ?? 0;
  const sourceWords = voice.words.slice(cursor, cursor + words.length);
  if (sourceWords.length !== words.length) {
    fail(`${group.id ?? `group ${groupIndex}`} does not map to available source words.`);
    continue;
  }

  const offset = voiceOffsets[voiceIndex];
  for (const [wordIndex, word] of words.entries()) {
    const sourceWord = sourceWords[wordIndex];
    const expectedStart = offset + sourceWord.start;
    const expectedEnd = offset + sourceWord.end;
    if (word.text !== sourceWord.text) {
      fail(`${group.id ?? `group ${groupIndex}`} changes source word ${sourceWord.id}.`);
    }
    if (!isClose(word.start, expectedStart) || !isClose(word.end, expectedEnd)) {
      fail(`${group.id ?? `group ${groupIndex}`} changes source timing for ${sourceWord.id}.`);
    }
  }

  const expectedGroupStart = offset + sourceWords[0].start;
  const expectedLastWordEnd = offset + sourceWords[sourceWords.length - 1].end;
  const nextSourceWord = voice.words[cursor + words.length];
  const nextBoundary = nextSourceWord
    ? offset + nextSourceWord.start
    : offset + voice.duration_s;
  if (!isClose(group.start, expectedGroupStart)) {
    fail(`${group.id ?? `group ${groupIndex}`} does not start on its first spoken word.`);
  }
  if (group.end + EPSILON < expectedLastWordEnd) {
    fail(`${group.id ?? `group ${groupIndex}`} ends before its last spoken word.`);
  }
  if (group.end > nextBoundary + EPSILON) {
    fail(`${group.id ?? `group ${groupIndex}`} runs into the next spoken word.`);
  }
  if (group.end - expectedLastWordEnd > MAX_HOLD_S) {
    fail(`${group.id ?? `group ${groupIndex}`} uses an unreadably long hold.`);
  }

  wordCursors.set(voiceIndex, cursor + words.length);
  groupsByVoice.set(voiceIndex, (groupsByVoice.get(voiceIndex) ?? 0) + 1);
  previousEnd = group.end;
  previousGroup = group;
}

for (const [voiceIndex, voice] of audioMeta.voices.entries()) {
  const consumedWords = wordCursors.get(voiceIndex) ?? 0;
  if (consumedWords !== voice.words.length) {
    fail(
      `Voice ${voice.frame} verbatim coverage is ${consumedWords}/${voice.words.length} words.`,
    );
  }
  if (!groupsByVoice.has(voiceIndex)) {
    fail(`Voice ${voice.frame} has no caption groups.`);
  }
}

for (const phrase of FIXED_PHRASES) {
  const isKeptTogether = groups.some((group) =>
    containsSequence(normalizeWords(group.words.map((word) => word.text)), phrase),
  );
  if (!isKeptTogether) {
    fail(`Fixed phrase "${phrase}" is split across caption groups.`);
  }
}

const sourceTextByVoice = audioMeta.voices.map((voice) =>
  voice.words.map((word) => word.text).join(" "),
);
const captionTextByVoice = audioMeta.voices.map((voice) =>
  groups
    .filter((group) => group.frame === voice.frame)
    .flatMap((group) => group.words.map((word) => word.text))
    .join(" "),
);
for (const [voiceIndex, sourceText] of sourceTextByVoice.entries()) {
  if (captionTextByVoice[voiceIndex] !== sourceText) {
    fail(`Voice ${voiceIndex + 1} caption text is not verbatim end-to-end.`);
  }
}

if (errors.length > 0) {
  console.error(`Caption validation failed (${errors.length} issue${errors.length === 1 ? "" : "s"}):`);
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exitCode = 1;
} else {
  console.log(
    `Caption validation passed: ${groups.length} groups, ${preferredSizeCount} in the preferred 3–8 word range, ${EXPECTED_FRAMES} frames / ${EXPECTED_DURATION_S}s, and verbatim coverage for ${audioMeta.voices.length} voice segments.`,
  );
}
