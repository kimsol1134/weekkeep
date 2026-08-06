import type { Metadata } from "next";
import { PhotoStoryMosaic } from "./components/PhotoStoryMosaic";
import { SiteShell } from "./components/SiteShell";

export const metadata: Metadata = {
  title: "A week worth keeping",
  description:
    "Weekkeep helps parents choose up to seven photos from the last week, privately on iPhone.",
};

export default function Home() {
  return (
    <SiteShell>
      <main>
        <section className="hero section-pad">
          <div className="hero-copy">
            <p className="eyebrow">PRIVATE WEEKLY PHOTO RITUAL</p>
            <h1>
              사진은 많은데,
              <br className="hero-break" />
              정리할 시간은{" "}
              <br className="hero-mobile-break" />
              없으니까.
            </h1>
            <p className="hero-lead">
              Weekkeep은 지난 일주일의 사진을 이 iPhone 안에서 살펴보고,
              최대 7장의 작은 앨범 초안을 준비해요. 마음에 들지 않는 한 장만
              바꾸고 그대로 남기세요.
            </p>
            <div className="hero-actions">
              <span className="status-pill">iPhone · iOS 18+ · 출시 준비 중</span>
              <a className="text-link" href="/privacy">
                개인정보 보호 방식 보기 <span aria-hidden="true">→</span>
              </a>
            </div>
          </div>

          <div className="photo-story-visual">
            <PhotoStoryMosaic />
          </div>
        </section>

        <section className="promise section-pad" aria-labelledby="promise-title">
          <div>
            <p className="eyebrow">ONE QUIET MINUTE A WEEK</p>
            <h2 id="promise-title">선택은 가볍게, 기억은 오래.</h2>
          </div>
          <ol className="steps">
            <li>
              <span>01</span>
              <h3>앱을 열어요</h3>
              <p>최근 완료된 일주일만 보여줘 밀린 숙제를 만들지 않아요.</p>
            </li>
            <li>
              <span>02</span>
              <h3>초안을 확인해요</h3>
              <p>기기 안에서 준비된 최대 7장을 보고, 원하는 사진만 바꿔요.</p>
            </li>
            <li>
              <span>03</span>
              <h3>한 주를 남겨요</h3>
              <p>선택한 기록은 계정이나 클라우드 없이 이 iPhone에 저장돼요.</p>
            </li>
          </ol>
        </section>

        <section className="privacy-callout section-pad">
          <div className="lock-mark" aria-hidden="true">⌁</div>
          <div>
            <p className="eyebrow">ON-DEVICE BY DESIGN</p>
            <h2>사진은 이 iPhone을 떠나지 않아요.</h2>
            <p>
              사진 분석은 foreground에서 기기 안에서만 이뤄집니다. 사진 픽셀,
              위치, 촬영 시각, 파일 이름, Photos 식별자를 분석 서비스나 구매
              서비스로 보내지 않습니다.
            </p>
          </div>
          <a className="secondary-button" href="/privacy">전체 개인정보 처리방침</a>
        </section>

        <section className="english-note section-pad" lang="en">
          <p className="eyebrow">FOR FAMILIES EVERYWHERE</p>
          <h2>A week worth keeping.</h2>
          <p>
            Weekkeep turns the last completed week on your iPhone into a small,
            private album of up to seven photos. No account. No photo upload. No
            backlog to catch up on.
          </p>
        </section>
      </main>
    </SiteShell>
  );
}
