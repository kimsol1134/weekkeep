import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import { BrandLockup } from "../components/AppFootage";
import { COLORS, FONT_FAMILY } from "../tokens";

export const Scene10EndCard = () => {
  const frame = useCurrentFrame();

  return (
    <AbsoluteFill
      style={{
        alignItems: "center",
        backgroundColor: COLORS.paper,
        color: COLORS.ink,
        display: "flex",
        fontFamily: FONT_FAMILY,
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      <div
        style={{
          alignItems: "center",
          display: "flex",
          flexDirection: "column",
          opacity: interpolate(frame, [0, 24], [0, 1], {
            easing: Easing.bezier(0.16, 1, 0.3, 1),
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          translate: `0px ${interpolate(frame, [0, 24], [12, 0], {
            easing: Easing.bezier(0.16, 1, 0.3, 1),
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          })}px`,
        }}
      >
        <BrandLockup width={430} />
        <div
          style={{
            color: COLORS.ink,
            fontSize: 48,
            fontWeight: 400,
            letterSpacing: -1.2,
            lineHeight: 1.15,
            marginTop: 54,
            textAlign: "center",
          }}
        >
          A week worth keeping.
        </div>
      </div>
      <div
        style={{
          bottom: 56,
          color: COLORS.mutedInk,
          fontSize: 14,
          fontWeight: 700,
          letterSpacing: 2.4,
          position: "absolute",
          textTransform: "uppercase",
        }}
      >
        RevenueCat Design Award · HAMM Award
      </div>
    </AbsoluteFill>
  );
};
