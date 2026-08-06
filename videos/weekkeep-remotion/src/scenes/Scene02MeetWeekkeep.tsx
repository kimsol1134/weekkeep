import { FootageVideo } from "../components/AppFootage";
import { SceneLayout } from "../components/SceneLayout";

export const Scene02MeetWeekkeep = () => (
  <SceneLayout
    sceneNumber="02"
    kicker="MEET WEEKKEEP"
    claim={
      <>
        Up to seven
        <br />
        moments.
      </>
    }
    supporting="A crowded camera roll becomes a small family album."
    railProgress={1}
  >
    <FootageVideo
      // The latest capture keeps the simulator home screen through ~5s and
      // has a short loading handoff before the review surface. Start on the
      // functioning review UI so the demo never shows pre-roll or a blank UI.
      trimBefore={360}
      durationInFrames={192}
      objectPosition="center 24%"
      scaleFrom={1.02}
    />
  </SceneLayout>
);
