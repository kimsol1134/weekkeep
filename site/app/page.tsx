import type { Metadata } from "next";
import { PhotoStoryMosaic } from "./components/PhotoStoryMosaic";
import { SiteShell } from "./components/SiteShell";

export const metadata: Metadata = {
  title: "A week worth keeping",
  description:
    "Weekkeep helps busy parents keep up to seven moments from the past week in a private iPhone album.",
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
              Weekkeep은 지난 일주일의 사진에서 다시 보고 싶은 순간을 최대 7장
              골라 작은 앨범으로 준비해요. 마음에 들지 않는 한 장만 바꾸고
              그대로 남기세요.
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
              <h3>준비된 순간을 확인해요</h3>
              <p>기기 안에서 준비된 최대 7장을 보고, 마음에 들지 않는 사진만 바꿔요.</p>
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
            <h2>사진 고르기는 이 iPhone 안에서 이뤄져요.</h2>
            <p>
              사진 고르기와 공유 이미지 만들기는 iPhone에서 처리해요. 사진·
              미리보기·파일 이름·위치·촬영 시각 같은 사진 정보는 분석을 위해
              다른 서비스로 보내지 않아요. 공유는 직접 선택할 때만 시작돼요.
            </p>
          </div>
          <a className="secondary-button" href="/privacy">전체 개인정보 처리방침</a>
        </section>

        <section className="english-note section-pad" lang="en">
          <p className="eyebrow">FOR FAMILIES EVERYWHERE</p>
          <h2>A week worth keeping.</h2>
          <p>
            Weekkeep turns the last completed week on your iPhone into a small,
            private album of up to seven moments. Photo selection and share
            rendering happen on your iPhone, and sharing starts only when you
            choose it. No account. No backlog to catch up on.
          </p>
        </section>
      </main>
    </SiteShell>
  );
}
