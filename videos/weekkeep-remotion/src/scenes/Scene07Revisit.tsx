import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene07Revisit = () => (
  <SceneLayout
    sceneNumber="07"
    kicker="ARCHIVE / NO PRESSURE"
    claim={
      <>
        Revisit,
        <br />
        without pressure.
      </>
    }
    supporting="No streak. No backlog. No account."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={960}
      durationInFrames={192}
      objectPosition="center 28%"
      scaleFrom={1.016}
    />
  </SceneLayout>
);
