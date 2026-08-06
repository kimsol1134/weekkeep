import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene05ParentEditor = () => (
  <SceneLayout
    sceneNumber="05"
    kicker="PARENT / EDITOR"
    claim={
      <>
        The parent
        <br />
        stays the editor.
      </>
    }
    supporting="Keep the draft, or change only the moment that does not feel right."
    railProgress={7}
  >
    <FootageVideo
      trimBefore={435}
      durationInFrames={222}
      objectPosition="center 55%"
      scaleFrom={1.016}
    />
  </SceneLayout>
);
