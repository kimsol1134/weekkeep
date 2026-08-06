import { loadFont } from "@remotion/fonts";
import { staticFile } from "remotion";

// loadFont() registers its own delayRender handle, so this stays compatible
// with Remotion's Chrome 85 bundle target without top-level await.
loadFont({
  family: "LINE Seed Sans KR",
  url: staticFile("fonts/LINE-Seed-Sans-KR-Regular.ttf"),
  weight: "400",
  style: "normal",
});
loadFont({
  family: "LINE Seed Sans KR",
  url: staticFile("fonts/LINE-Seed-Sans-KR-Bold.ttf"),
  weight: "700",
  style: "normal",
});
