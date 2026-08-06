import { SevenStitches } from "./SevenStitches";

const fixturePhotos = [
  ["01-ginkgo-leaf.png", "Ginkgo leaf moment"],
  ["02-pancake-morning.png", "Pancake morning moment"],
  ["03-rainy-puddle.png", "Rainy puddle moment"],
  ["04-bedtime-story.png", "Bedtime story moment"],
  ["05-park-bubbles.png", "Park bubbles moment"],
  ["06-acorn-home.png", "Acorn at home moment"],
  ["07-balcony-herbs.png", "Balcony herbs moment"],
] as const;

const fixtureRoot = "/fixtures/app-store-family-moments";

export function PhotoStoryMosaic() {
  return (
    <div
      className="photo-story"
      role="img"
      aria-label="A Weekkeep story made from seven approved sample photos"
    >
      <div className="photo-story-rail">
        <span className="photo-story-rail-label">SEVEN MOMENTS</span>
        <SevenStitches compact />
      </div>
      <div className="photo-story-grid">
        <PhotoTile photo={fixturePhotos[0]} className="photo-story-tile--hero" />
        <div className="photo-story-row photo-story-row--middle">
          {fixturePhotos.slice(1, 3).map((photo) => (
            <PhotoTile key={photo[0]} photo={photo} />
          ))}
        </div>
        <div className="photo-story-row photo-story-row--bottom">
          {fixturePhotos.slice(3).map((photo) => (
            <PhotoTile key={photo[0]} photo={photo} />
          ))}
        </div>
      </div>
    </div>
  );
}

function PhotoTile({
  photo,
  className = "",
}: {
  photo: readonly [string, string];
  className?: string;
}) {
  return (
    <img
      className={`photo-story-tile ${className}`.trim()}
      src={`${fixtureRoot}/${photo[0]}`}
      alt=""
      aria-hidden="true"
    />
  );
}
