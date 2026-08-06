import { Audio } from "@remotion/media";
import { fade } from "@remotion/transitions/fade";
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import {
  AbsoluteFill,
  Composition,
  Folder,
  Sequence,
  staticFile,
} from "remotion";
import audioMeta from "./data/audio_meta.json";
import { Captions } from "./components/Captions";
import { Scene01QuietMinute } from "./scenes/Scene01QuietMinute";
import { Scene02MeetWeekkeep } from "./scenes/Scene02MeetWeekkeep";
import { Scene03OnDevice } from "./scenes/Scene03OnDevice";
import { Scene04SevenIsALimit } from "./scenes/Scene04SevenIsALimit";
import { Scene05ParentEditor } from "./scenes/Scene05ParentEditor";
import { Scene06SaveAndShare } from "./scenes/Scene06SaveAndShare";
import { Scene07Revisit } from "./scenes/Scene07Revisit";
import { Scene08QuietByDefault } from "./scenes/Scene08QuietByDefault";
import { Scene09PlusOnce } from "./scenes/Scene09PlusOnce";
import { Scene10EndCard } from "./scenes/Scene10EndCard";
import { COLORS } from "./tokens";

const narrationSrc = (index: number) =>
  staticFile(audioMeta.voices[index].path.replace("assets/", "audio/"));

const bgmSrc = staticFile(audioMeta.bgm.path.replace("assets/", "audio/"));

export const WeekkeepShipaton72 = () => (
  <AbsoluteFill style={{ backgroundColor: COLORS.paper }}>
    <TransitionSeries name="Weekkeep editorial timeline">
      <TransitionSeries.Sequence name="01 Quiet minute" durationInFrames={192}>
        <Scene01QuietMinute />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="02 Meet Weekkeep" durationInFrames={192}>
        <Scene02MeetWeekkeep />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="03 On-device" durationInFrames={357}>
        <Scene03OnDevice />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="04 Seven is a limit" durationInFrames={282}>
        <Scene04SevenIsALimit />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="05 Parent editor" durationInFrames={222}>
        <Scene05ParentEditor />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="06 Save and share" durationInFrames={162}>
        <Scene06SaveAndShare />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="07 Revisit" durationInFrames={192}>
        <Scene07Revisit />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="08 Quiet by default" durationInFrames={222}>
        <Scene08QuietByDefault />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="09 Plus once" durationInFrames={312}>
        <Scene09PlusOnce />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 12 })}
      />
      <TransitionSeries.Sequence name="10 End card" durationInFrames={135}>
        <Scene10EndCard />
      </TransitionSeries.Sequence>
    </TransitionSeries>

    <Audio src={bgmSrc} volume={0.11} />
    <Sequence from={0} durationInFrames={180} layout="none">
      <Audio src={narrationSrc(0)} />
    </Sequence>
    <Sequence from={180} durationInFrames={180} layout="none">
      <Audio src={narrationSrc(1)} />
    </Sequence>
    <Sequence from={360} durationInFrames={345} layout="none">
      <Audio src={narrationSrc(2)} />
    </Sequence>
    <Sequence from={705} durationInFrames={270} layout="none">
      <Audio src={narrationSrc(3)} />
    </Sequence>
    <Sequence from={975} durationInFrames={210} layout="none">
      <Audio src={narrationSrc(4)} />
    </Sequence>
    <Sequence from={1185} durationInFrames={150} layout="none">
      <Audio src={narrationSrc(5)} />
    </Sequence>
    <Sequence from={1335} durationInFrames={180} layout="none">
      <Audio src={narrationSrc(6)} />
    </Sequence>
    <Sequence from={1515} durationInFrames={210} layout="none">
      <Audio src={narrationSrc(7)} />
    </Sequence>
    <Sequence from={1725} durationInFrames={300} layout="none">
      <Audio src={narrationSrc(8)} />
    </Sequence>
    <Sequence from={2025} durationInFrames={135} layout="none">
      <Audio src={narrationSrc(9)} />
    </Sequence>
    <Captions />
  </AbsoluteFill>
);

export const RemotionRoot = () => (
  <>
    <Folder name="Weekkeep-Shipaton">
      <Composition
        id="WeekkeepShipaton72"
        component={WeekkeepShipaton72}
        durationInFrames={2160}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{}}
      />
    </Folder>
  </>
);
