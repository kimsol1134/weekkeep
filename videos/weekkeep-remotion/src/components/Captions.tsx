import type { Caption } from "@remotion/captions";
import { Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import captionData from "../data/caption_groups.json";
import { COLORS, FONT_FAMILY } from "../tokens";

type CaptionGroup = Caption & {
  readonly frame: number;
};

const CAPTIONS: CaptionGroup[] = captionData.groups.map((group) => ({
  text: group.text,
  startMs: Math.round(group.start * 1000),
  endMs: Math.round(group.end * 1000),
  timestampMs: null,
  confidence: null,
  frame: group.frame,
}));

const LONG_CAPTION_CHARACTER_LIMIT = 50;
const BASE_CAPTION_FONT_SIZE = 30;
const LONG_CAPTION_FONT_SIZE = 28;

export const capitalizeFirstDisplayedGlyph = (text: string) =>
  text.replace(/^\p{Ll}/u, (glyph) => glyph.toLocaleUpperCase("en-US"));

const getCaptionFontSize = (text: string) =>
  text.length > LONG_CAPTION_CHARACTER_LIMIT
    ? LONG_CAPTION_FONT_SIZE
    : BASE_CAPTION_FONT_SIZE;

export const Captions = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const current = CAPTIONS.find((caption) => {
    const startFrame = (caption.startMs / 1000) * fps;
    const endFrame = (caption.endMs / 1000) * fps;
    return frame >= startFrame && frame < endFrame;
  });

  if (!current) {
    return null;
  }
  if (current.frame === 10) {
    return null;
  }

  const startFrame = (current.startMs / 1000) * fps;
  const endFrame = (current.endMs / 1000) * fps;
  const fadeFrames = Math.min(12, Math.max(3, (endFrame - startFrame) / 4));
  const accentColor = COLORS.stitches[(current.frame - 1) % COLORS.stitches.length];
  const displayText = capitalizeFirstDisplayedGlyph(current.text);

  return (
    <div
      aria-label={`Caption: ${current.text}`}
      style={{
        backgroundColor: COLORS.plum,
        border: `1px solid ${COLORS.quietLine}`,
        borderLeft: `6px solid ${accentColor}`,
        borderRadius: 12,
        bottom: 118,
        boxSizing: "border-box",
        color: COLORS.paper,
        display: "flex",
        alignItems: "center",
        fontFamily: FONT_FAMILY,
        fontSize: getCaptionFontSize(current.text),
        fontWeight: 700,
        left: 80,
        letterSpacing: -0.6,
        lineHeight: 1.16,
        maxWidth: 520,
        minHeight: 68,
        opacity: interpolate(
          frame,
          [startFrame, startFrame + fadeFrames, endFrame - fadeFrames, endFrame],
          [0, 1, 1, 0],
          {
            easing: Easing.bezier(0.16, 1, 0.3, 1),
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          },
        ),
        padding: "16px 22px 18px",
        position: "absolute",
        textAlign: "left",
        whiteSpace: "normal",
        zIndex: 10,
      }}
    >
      <span
        style={{
          display: "block",
          textWrap: "balance",
          width: "100%",
        }}
      >
        {displayText}
      </span>
    </div>
  );
};
