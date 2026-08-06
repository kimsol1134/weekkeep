import { Sequence } from "remotion";
import { AppScreenshot, FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene09PlusOnce = () => (
  <SceneLayout
    sceneNumber="09"
    kicker="PLUS / ONCE"
    claim={
      <>
        Plus,
        <br />
        once.
      </>
    }
    supporting="Two albums are free. Then one lifetime purchase."
    railProgress={7}
  >
    <FootageVideo
      // Reuse the saved-week surface for the first two seconds, then hold the
      // approved paywall. The old 44s trim crossed into simulator home-screen
      // footage in the latest capture.
      trimBefore={1110}
      durationInFrames={60}
      objectPosition="center 12%"
      scaleFrom={1.01}
    />
    <Sequence from={60} durationInFrames={252} layout="none">
      <AppScreenshot src="screenshots/09-paywall-price.jpg" objectPosition="center 74%" />
    </Sequence>
  </SceneLayout>
);
