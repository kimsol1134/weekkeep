import { Video } from "@remotion/media";
import {
  CanvasImage,
  Easing,
  Img,
  interpolate,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { FOOTAGE_PATH } from "../tokens";

type FootageVideoProps = {
  readonly trimBefore: number;
  readonly durationInFrames: number;
  readonly objectPosition?: string;
  readonly scaleFrom?: number;
};

export const FootageVideo = ({
  trimBefore,
  durationInFrames,
  objectPosition = "center center",
  scaleFrom = 1.018,
}: FootageVideoProps) => {
  const frame = useCurrentFrame();

  return (
    <Video
      src={staticFile(FOOTAGE_PATH)}
      muted
      objectFit="cover"
      trimBefore={trimBefore}
      durationInFrames={durationInFrames}
      style={{
        height: "100%",
        left: 0,
        objectFit: "cover",
        objectPosition,
        position: "absolute",
        scale: interpolate(frame, [0, durationInFrames], [scaleFrom, 1], {
          easing: Easing.linear,
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          output: "perceptual-scale",
        }),
        top: 0,
        transformOrigin: "center center",
        width: "100%",
      }}
    />
  );
};

type AppScreenshotProps = {
  readonly src: string;
  readonly objectPosition?: string;
};

export const AppScreenshot = ({
  src,
  objectPosition = "center center",
}: AppScreenshotProps) => {
  const frame = useCurrentFrame();

  return (
    <CanvasImage
      src={staticFile(src)}
      style={{
        height: "100%",
        left: 0,
        objectFit: "cover",
        objectPosition,
        position: "absolute",
        scale: interpolate(frame, [0, 36], [1.012, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          output: "perceptual-scale",
        }),
        top: 0,
        transformOrigin: "center center",
        width: "100%",
      }}
    />
  );
};

type BrandLockupProps = {
  readonly width: number;
};

export const BrandLockup = ({ width }: BrandLockupProps) => (
  <Img
    src={staticFile("brand/weekkeep-lockup.svg")}
    alt="weekkeep"
    style={{
      display: "block",
      height: "auto",
      width,
    }}
  />
);
