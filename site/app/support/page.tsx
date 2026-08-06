import type { Metadata } from "next";
import { SiteShell } from "../components/SiteShell";

export const metadata: Metadata = {
  title: "Help & Support",
  description: "Weekkeep help, troubleshooting, purchase restore, and contact information.",
};

const faqs = [
  {
    title: "사진 접근을 허용했는데 사진이 적게 보여요.",
    body: "제한된 사진 접근을 선택했거나, 최근 완료된 주간에 조건을 만족하는 사진이 적을 수 있어요. iOS 설정 › 앱 › Weekkeep › 사진에서 접근 범위를 확인하세요.",
    en: "If you chose Limited Photos or the last completed week contains few eligible photos, Weekkeep may show fewer results. Check iOS Settings › Apps › Weekkeep › Photos.",
  },
  {
    title: "항상 7장이 나오나요?",
    body: "아니요. Weekkeep은 최대 7장을 제안해요. 허용된 사진이 적거나 분석 기준을 통과한 후보가 부족하면 1–6장으로 정직하게 보여줍니다.",
    en: "No. Weekkeep suggests up to seven photos. If fewer eligible photos are available, it shows an honest 1–6 photo result.",
  },
  {
    title: "저장한 사진이 보이지 않아요.",
    body: "Weekkeep은 Photos의 원본을 참조합니다. 원본 사진을 삭제했거나 접근 범위를 바꿨다면 표시할 수 없어요. Recently Deleted와 사진 접근 설정을 확인하세요.",
    en: "Weekkeep references originals in Photos. A photo may become unavailable if the original was deleted or access changed. Check Recently Deleted and Photos permission.",
  },
  {
    title: "앱을 지우거나 기기를 바꾸면 기록이 복원되나요?",
    body: "아니요. V1은 계정, Weekkeep 클라우드 백업, 기기 간 앨범 복원을 제공하지 않아요. 앱 삭제나 기기 변경 시 주간 기록이 사라질 수 있습니다.",
    en: "No. V1 has no account, Weekkeep cloud backup, or cross-device album restore. Weekly records can be lost after app deletion or a device change.",
  },
  {
    title: "Plus 구매를 복원하고 싶어요.",
    body: "앱의 설정 › 도움말 및 문의 › 구매 복원을 사용하세요. 구매할 때와 같은 Apple ID가 필요합니다. 복원은 Plus 기능만 되살리며 앨범 데이터는 복원하지 않습니다.",
    en: "Use Settings › Help & Support › Restore Purchases with the same Apple ID used to buy Plus. Restore recovers feature access, not album data.",
  },
  {
    title: "결제 취소나 환불은 어디서 하나요?",
    body: "App Store 결제와 환불은 Apple이 처리합니다. reportaproblem.apple.com에서 구매 내역을 선택해 요청할 수 있어요.",
    en: "Apple handles App Store billing and refunds. Visit reportaproblem.apple.com, choose the purchase, and follow Apple’s process.",
  },
  {
    title: "알림 시간을 바꾸거나 끄고 싶어요.",
    body: "Weekkeep 설정에서 매주 월요일 오후 8시 30분 로컬 알림을 켜거나 끌 수 있어요. 모든 알림 권한은 iOS 설정 › 알림 › Weekkeep에서 관리합니다.",
    en: "Manage the Monday 8:30 PM local reminder in Weekkeep Settings, and system permission in iOS Settings › Notifications › Weekkeep.",
  },
  {
    title: "사진이 서버나 분석 도구로 전송되나요?",
    body: "아니요. 사진 픽셀, 썸네일, 파일명, 위치, 촬영 시각, Photos 식별자는 기기를 떠나지 않아요. 구매 상태와 선택적 coarse 제품 이벤트는 개인정보 처리방침에 공개한 범위에서만 별도 처리합니다.",
    en: "No photo pixels, thumbnails, file names, locations, timestamps, or Photos identifiers leave the device. Purchase status and optional coarse product events are handled separately as disclosed in the Privacy Policy.",
  },
];

export default function SupportPage() {
  return (
    <SiteShell>
      <main>
        <header className="document-hero section-pad">
          <p className="eyebrow">HELP & SUPPORT</p>
          <h1>막히는 순간이 없도록.</h1>
          <p className="lede">
            사진 접근, 저장 기록, 알림, Plus 구매 복원에 관한 빠른 답을
            확인하세요. 해결되지 않으면 아래 이메일로 직접 도와드릴게요.
          </p>
          <div className="document-meta">
            <span>Weekkeep for iPhone · iOS 18+</span>
            <span>한국어 / English support</span>
          </div>
        </header>

        <section className="section-pad" aria-labelledby="faq-title">
          <p className="eyebrow">QUICK ANSWERS</p>
          <h2 id="faq-title">자주 묻는 질문</h2>
          <div className="faq-grid">
            {faqs.map((faq) => (
              <article className="faq-card" key={faq.title}>
                <h2>{faq.title}</h2>
                <p>{faq.body}</p>
                <p lang="en" style={{ marginTop: "16px" }}>{faq.en}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="document-body section-pad" style={{ paddingTop: "96px" }}>
          <section className="document-section">
            <h2>문의할 때 함께 보내주세요</h2>
            <ul>
              <li>iPhone 모델과 iOS 버전</li>
              <li>Weekkeep 버전 (설정 › 도움말 및 문의에서 확인)</li>
              <li>문제가 발생한 화면과 재현 순서</li>
              <li>가능하면 개인정보를 가린 스크린샷</li>
            </ul>
            <p lang="en">Please include your iPhone model, iOS version, Weekkeep version, the screen where the issue occurred, and steps to reproduce it. Remove or cover private photo content before attaching screenshots.</p>
            <div className="notice">
              <p><strong>사진 원본은 보내지 않아도 됩니다.</strong> 지원 과정에서도 아이 사진, Photos 식별자, 위치·촬영 시각을 요청하지 않습니다.</p>
            </div>
          </section>

          <section className="document-section">
            <h2>개인정보 또는 데이터 삭제 요청</h2>
            <p>앱의 로컬 기록은 앱 삭제로 제거할 수 있습니다. RevenueCat 또는 활성화된 분석 서비스가 처리한 정보의 열람·삭제 문의는 제목에 “Weekkeep Privacy”를 적어 이메일로 보내주세요. 요청 대상 확인에 필요한 최소 정보만 안내합니다.</p>
            <p lang="en">Local records can be removed by deleting the app. For an access or deletion request involving RevenueCat or enabled analytics services, email us with “Weekkeep Privacy” in the subject. We will ask only for the minimum information needed to locate the request.</p>
          </section>
        </section>

        <section className="contact-card section-pad">
          <div>
            <h2>그래도 해결되지 않았나요?</h2>
            <p>평일 기준 가능한 한 2영업일 안에 답변드리겠습니다.<br /><span lang="en">We aim to reply within two business days.</span></p>
          </div>
          <a className="primary-button" href="mailto:kimsol1134@gmail.com?subject=Weekkeep%20Support">kimsol1134@gmail.com</a>
        </section>
      </main>
    </SiteShell>
  );
}
