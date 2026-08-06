import { useCurrentFrame, interpolate } from "remotion";
import {
  COLORS,
  SEVEN_STITCH_COUNT,
  SEVEN_STITCH_VISIBILITY_FLOOR,
} from "../tokens";

type SevenStitchRailProps = {
  readonly progress?: number;
  readonly scale?: number;
};

type StitchProps = {
  readonly color: string;
  readonly slot: number;
  readonly progress: number;
  readonly frame: number;
  readonly compactScale: number;
};

const Stitch = ({
  color,
  slot,
  progress,
  frame,
  compactScale,
}: StitchProps) => {
  const isComplete = slot < progress;
  const targetOpacity = isComplete ? 1 : SEVEN_STITCH_VISIBILITY_FLOOR;
  return (
    <span
      aria-hidden="true"
      style={{
        width: 28 * compactScale,
        height: 8 * compactScale,
        borderRadius: 999,
        backgroundColor: color,
        display: "block",
        opacity: interpolate(frame, [0, 12], [SEVEN_STITCH_VISIBILITY_FLOOR, targetOpacity], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        }),
        scale: isComplete ? 1 : 0.82,
        transformOrigin: "left center",
      }}
    />
  );
};

export const SevenStitchRail = ({
  progress = 7,
  scale: compactScale = 1,
}: SevenStitchRailProps) => {
  const frame = useCurrentFrame();

  return (
    <div
      aria-label={`Seven stitch progress, ${progress} of ${SEVEN_STITCH_COUNT}`}
      style={{
        alignItems: "center",
        display: "flex",
        gap: 9 * compactScale,
        height: 16 * compactScale,
      }}
    >
      {Array.from({ length: SEVEN_STITCH_COUNT }, (_, slot) => (
        <Stitch
          key={slot}
          color={COLORS.stitches[slot]}
          slot={slot}
          progress={progress}
          frame={frame}
          compactScale={compactScale}
        />
      ))}
    </div>
  );
};
