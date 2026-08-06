import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene01QuietMinute = () => (
  <SceneLayout
    sceneNumber="01"
    kicker="ONE QUIET MINUTE"
    claim={
      <>
        One quiet
        <br />
        minute.
      </>
    }
    supporting="Keep the week, not another daily habit."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={720}
      durationInFrames={192}
      objectPosition="center 25%"
      scaleFrom={1.012}
    />
  </SceneLayout>
);
