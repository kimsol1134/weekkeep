export const COLORS = {
  paper: "#FBF7F2",
  plum: "#5B415E",
  ink: "#25212B",
  mutedInk: "#6F6670",
  quietLine: "#E5DED7",
  stitches: [
    "#E97A68",
    "#E39455",
    "#E5A84B",
    "#66836E",
    "#5F879B",
    "#686286",
    "#8A6386",
  ] as const,
} as const;

export const SEVEN_STITCH_VISIBILITY_FLOOR = 0.58 as const;
export const SEVEN_STITCH_COUNT = 7 as const;

export const FONT_FAMILY = "LINE Seed Sans KR";

export const FOOTAGE_PATH = "footage/weekkeep-remotion-ui.mp4";

export const VIEWPORT = {
  copyWidth: 600,
  footageWidth: 1320,
  width: 1920,
  height: 1080,
} as const;
