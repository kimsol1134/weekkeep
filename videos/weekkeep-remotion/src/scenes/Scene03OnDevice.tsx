import { Sequence } from "remotion";
import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene03OnDevice = () => (
  <SceneLayout
    sceneNumber="03"
    kicker="TRUST BEFORE ACCESS"
    claim={
      <>
        On-device,
        <br />
        by default.
      </>
    }
    supporting="Photos stay on this iPhone. No upload is part of the flow."
    railProgress={2}
  >
    <Sequence from={0} durationInFrames={72} layout="none">
      <FootageVideo
        trimBefore={210}
        durationInFrames={72}
        objectPosition="center 29%"
        scaleFrom={1.014}
      />
    </Sequence>
    <Sequence from={72} durationInFrames={285} layout="none">
      <FootageVideo
        trimBefore={360}
        durationInFrames={285}
        objectPosition="center 29%"
        scaleFrom={1.014}
      />
    </Sequence>
  </SceneLayout>
);
