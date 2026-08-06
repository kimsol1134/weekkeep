import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene04SevenIsALimit = () => (
  <SceneLayout
    sceneNumber="04"
    kicker="A DRAFT, NOT A DEMAND"
    claim={
      <>
        Seven is
        <br />
        a limit.
      </>
    }
    supporting="If a week has fewer usable photos, Weekkeep shows fewer."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={360}
      durationInFrames={282}
      objectPosition="center 28%"
      scaleFrom={1.018}
    />
  </SceneLayout>
);
