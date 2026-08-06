import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene06SaveAndShare = () => (
  <SceneLayout
    sceneNumber="06"
    kicker="SAVE THE WEEK"
    claim={
      <>
        Save the
        <br />
        week.
      </>
    }
    supporting="One tap saves a small weekly album locally."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={570}
      durationInFrames={162}
      objectPosition="center 8%"
      scaleFrom={1.012}
    />
  </SceneLayout>
);
