import type { ReactNode } from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import { COLORS, FONT_FAMILY, VIEWPORT } from "../tokens";
import { SevenStitchRail } from "./SevenStitchRail";

type SceneLayoutProps = {
  readonly sceneNumber: string;
  readonly kicker: string;
  readonly claim: ReactNode;
  readonly supporting: string;
  readonly railProgress: number;
  readonly children: ReactNode;
};

export const SceneLayout = ({
  sceneNumber,
  kicker,
  claim,
  supporting,
  railProgress,
  children,
}: SceneLayoutProps) => {
  const frame = useCurrentFrame();

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.paper,
        color: COLORS.ink,
        fontFamily: FONT_FAMILY,
        overflow: "hidden",
      }}
    >
      <div
        style={{
          backgroundColor: COLORS.paper,
          height: "100%",
          left: 0,
          position: "absolute",
          top: 0,
          width: VIEWPORT.copyWidth,
          zIndex: 3,
        }}
      >
        <div
          style={{
            left: 80,
            opacity: interpolate(frame, [0, 18], [0, 1], {
              easing: Easing.bezier(0.16, 1, 0.3, 1),
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
            position: "absolute",
            top: 72,
            translate: `0px ${interpolate(frame, [0, 18], [10, 0], {
              easing: Easing.bezier(0.16, 1, 0.3, 1),
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })}px`,
          }}
        >
          <div
            style={{
              color: COLORS.mutedInk,
              fontSize: 16,
              fontWeight: 700,
              letterSpacing: 2.5,
              lineHeight: 1,
              marginBottom: 30,
              textTransform: "uppercase",
            }}
          >
            {kicker}
          </div>
          <SevenStitchRail progress={railProgress} scale={0.8} />
          <div
            style={{
              color: COLORS.plum,
              fontFamily: FONT_FAMILY,
              fontSize: 84,
              fontWeight: 700,
              letterSpacing: -3.2,
              lineHeight: 0.98,
              marginTop: 54,
              maxWidth: 500,
            }}
          >
            {claim}
          </div>
          <div
            style={{
              borderLeft: `2px solid ${COLORS.stitches[0]}`,
              color: COLORS.ink,
              fontSize: 28,
              fontWeight: 400,
              lineHeight: 1.25,
              marginTop: 46,
              maxWidth: 470,
              paddingLeft: 20,
            }}
          >
            {supporting}
          </div>
        </div>
        <div
          style={{
            bottom: 54,
            color: COLORS.mutedInk,
            fontSize: 14,
            fontWeight: 700,
            left: 80,
            letterSpacing: 2.2,
            position: "absolute",
            textTransform: "uppercase",
          }}
        >
          {sceneNumber} / 10
        </div>
      </div>

      <div
        aria-label="Actual Weekkeep app footage"
        style={{
          backgroundColor: "#F3ECE5",
          borderLeft: `1px solid ${COLORS.quietLine}`,
          height: "100%",
          left: VIEWPORT.copyWidth,
          overflow: "hidden",
          position: "absolute",
          top: 0,
          width: VIEWPORT.footageWidth,
          zIndex: 1,
        }}
      >
        {children}
      </div>
    </AbsoluteFill>
  );
};
