import { Sequence } from "remotion";
import { AppScreenshot, FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene08QuietByDefault = () => (
  <SceneLayout
    sceneNumber="08"
    kicker="QUIET BY DEFAULT"
    claim={
      <>
        Quiet
        <br />
        by default.
      </>
    }
    supporting="An optional Monday reminder stays on device."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={1185}
      durationInFrames={138}
      objectPosition="center 18%"
      scaleFrom={1.012}
    />
    <Sequence from={138} durationInFrames={84} layout="none">
      <AppScreenshot src="screenshots/07-settings.jpg" objectPosition="center 20%" />
    </Sequence>
  </SceneLayout>
);
