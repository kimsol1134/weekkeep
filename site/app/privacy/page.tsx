import type { Metadata } from "next";
import { SiteShell } from "../components/SiteShell";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "How Weekkeep handles photos, local records, purchases, analytics, and support requests.",
};

export default function PrivacyPage() {
  return (
    <SiteShell>
      <main>
        <header className="document-hero section-pad">
          <p className="eyebrow">PRIVACY POLICY</p>
          <h1>사진은 추억이고,<br />추적 데이터가 아닙니다.</h1>
          <p className="lede">
            Weekkeep은 사진 고르기와 공유 이미지 만들기를 iPhone 안에서 처리하도록 설계했습니다.
            이 문서는 사진, 기기 내 기록, 구매 상태, 선택적 제품 분석 데이터를
            각각 어떻게 다루는지 설명합니다.
          </p>
          <div className="document-meta">
            <span>시행일 / Effective: 2026-08-05</span>
            <span>운영자 / Operator: Weekkeep (김솔 / Sol Kim)</span>
          </div>
        </header>

        <div className="document-layout section-pad">
          <nav className="document-nav" aria-label="Privacy policy sections">
            <strong>CONTENTS</strong>
            <a href="#summary">핵심 요약</a>
            <a href="#data">처리하는 데이터</a>
            <a href="#photos">사진과 로컬 기록</a>
            <a href="#vendors">외부 서비스</a>
            <a href="#retention">보관과 삭제</a>
            <a href="#rights">선택과 권리</a>
            <a href="#english">English</a>
            <a href="#contact">문의</a>
          </nav>

          <article className="document-body">
            <section className="document-section" id="summary">
              <h2>1. 핵심 요약</h2>
              <ul>
                <li>사진 고르기와 공유 이미지 만들기는 사용자의 iPhone에서 처리합니다. 사진 픽셀, 썸네일, 파일명, 위치, 촬영 시각, Photos 식별자 같은 사진 정보는 분석을 위해 분석 서비스나 다른 서비스로 보내지 않습니다. 공유는 사용자가 직접 선택할 때만 시작합니다.</li>
                <li>선택한 주간 기록은 계정이나 Weekkeep 클라우드가 아니라 앱의 로컬 저장소에 보관됩니다.</li>
                <li>앱 삭제, 기기 변경, 원본 사진 삭제 또는 사진 접근 권한 변경 시 기록이 보이지 않거나 사라질 수 있습니다.</li>
                <li>구매·복원 기능을 사용할 때 RevenueCat이 익명 앱 사용자 식별자와 구매 상태를 처리할 수 있습니다.</li>
                <li>제품 분석이 활성화된 빌드에서는 PostHog EU Cloud로 사진과 무관한 제한된 사용 이벤트만 전송합니다.</li>
                <li>광고, 타사 앱·웹사이트 간 추적, 생체 신원 식별, 개인정보 판매를 하지 않습니다.</li>
              </ul>
              <div className="notice">
                <p><strong>중요:</strong> 사진 고르기와 공유 이미지 만들기는 iPhone에서 처리합니다. 사진 정보는 분석을 위해 외부 서비스로 보내지 않으며, 공유는 사용자가 직접 선택할 때만 시작합니다. 구매 처리와 선택적 제품 분석은 아래와 같이 별도로 공개합니다.</p>
              </div>
            </section>

            <section className="document-section" id="data">
              <h2>2. 처리하는 데이터</h2>
              <div className="data-table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>구분</th>
                      <th>항목</th>
                      <th>목적</th>
                      <th>처리 위치</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>사진 접근</td>
                      <td>사용자가 허용한 Photos 자산과 권한 상태</td>
                      <td>지난 주 후보 탐색, 기기 내 품질·중복 분석, 화면 표시</td>
                      <td>사용자의 iPhone</td>
                    </tr>
                    <tr>
                      <td>주간 기록</td>
                      <td>주간 범위, 선택 순서, 로컬 Photos 식별자, 교체·알림 설정</td>
                      <td>저장한 앨범 재표시와 앱 상태 유지</td>
                      <td>앱 로컬 저장소</td>
                    </tr>
                    <tr>
                      <td>구매</td>
                      <td>익명 앱 사용자 ID, 상품 ID, 구매·복원·구독 아닌 entitlement 상태</td>
                      <td>Plus 평생 이용권 확인과 복원</td>
                      <td>Apple App Store 및 RevenueCat</td>
                    </tr>
                    <tr>
                      <td>선택적 분석</td>
                      <td>앱 버전·언어, 권한 결과, 구간화된 후보 수·소요 시간, 선택·교체 수, 구매 결과</td>
                      <td>오류 지점과 제품 흐름 개선</td>
                      <td>활성화 시 PostHog EU Cloud</td>
                    </tr>
                    <tr>
                      <td>문의</td>
                      <td>사용자가 이메일에 직접 작성한 주소와 내용</td>
                      <td>지원 요청 답변</td>
                      <td>이메일 서비스</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <p>Weekkeep은 계정, 프로필, 아이의 이름·나이, 주소록, 광고 식별자, 정밀 위치를 요구하지 않습니다.</p>
            </section>

            <section className="document-section" id="photos">
              <h2>3. 사진과 기기 내 기록</h2>
              <h3>권한을 요청하는 시점</h3>
              <p>앱을 설치하거나 첫 화면을 보는 것만으로 사진 권한을 요청하지 않습니다. 사용자가 사진 고르기를 직접 시작한 뒤 iOS 권한 화면을 표시합니다. 제한된 접근을 선택한 경우 허용된 사진만 다룹니다.</p>
              <h3>기기 내 분석</h3>
              <p>이미지 축소, 미학 품질 추정, 흐림·노출·중복 신호 계산과 후보 정렬은 앱이 foreground에 있는 동안 Apple Photos/Vision 프레임워크를 이용해 기기에서 실행됩니다. 사용자가 공유를 선택하면 공유 이미지 렌더링도 iPhone에서 처리한 뒤 Apple 시스템 공유 시트를 엽니다. 얼굴을 특정 사람으로 식별하거나 아이의 신원을 학습하지 않습니다.</p>
              <h3>저장 방식과 한계</h3>
              <p>원본 사진 바이너리를 앱 샌드박스에 복제하지 않고 Photos 자산을 참조합니다. 따라서 원본을 사진 앱에서 삭제하거나 접근을 해제하면 해당 사진을 다시 표시하지 못할 수 있습니다. Weekkeep은 계정, 자체 서버 백업, CloudKit 동기화, 기기 간 앨범 복원을 제공하지 않습니다.</p>
            </section>

            <section className="document-section" id="vendors">
              <h2>4. 외부 서비스와 국외 처리</h2>
              <h3>Apple App Store</h3>
              <p>결제, 환불, Apple ID 기반 구매 복원은 Apple이 운영합니다. Apple의 데이터 처리는 Apple의 개인정보 보호정책과 App Store 약관을 따릅니다.</p>
              <h3>RevenueCat, Inc. — 미국</h3>
              <p>사용자가 Plus 구매 또는 복원을 시도하면 익명 앱 사용자 ID, 상품·거래·entitlement 상태가 암호화된 연결로 RevenueCat에 전달될 수 있습니다. 목적은 결제 상태 확인과 구매 복원입니다. 사진 데이터와 가족 정보는 전달하지 않습니다. 관련 데이터는 entitlement 운영, 분쟁 대응 및 법적 의무에 필요한 기간 보관될 수 있습니다. 자세한 내용은 <a href="https://www.revenuecat.com/privacy/" rel="noreferrer">RevenueCat Privacy Policy</a>를 참고하세요.</p>
              <h3>PostHog EU Cloud — 유럽연합</h3>
              <p>제품 분석이 활성화된 출시 빌드에서는 명시적으로 허용한 coarse event만 EU endpoint로 전송합니다. 자동 화면 캡처, session replay, element autocapture, person profile, 사용자 식별, 광고 ID, feature flag, survey, tracing, 자동 crash capture는 비활성화합니다. 이벤트에는 사진 픽셀·식별자·파일명·위치·촬영 시각·week key·자유 입력 텍스트가 포함되지 않습니다. 비활성화된 빌드에서는 PostHog 전송이 발생하지 않습니다. 자세한 내용은 <a href="https://posthog.com/privacy" rel="noreferrer">PostHog Privacy Notice</a>를 참고하세요.</p>
              <p>외부 서비스 구성이나 실제 전송 항목이 바뀌면 앱 출시 전에 이 문서와 App Store 개인정보 공개를 함께 갱신합니다.</p>
            </section>

            <section className="document-section" id="retention">
              <h2>5. 보관과 삭제</h2>
              <ul>
                <li><strong>기기 내 기록:</strong> 사용자가 앱을 삭제하거나 앱 데이터가 제거될 때까지 기기에 남습니다. 별도 서버 사본은 없습니다.</li>
                <li><strong>원본 사진:</strong> Weekkeep이 소유하거나 삭제하지 않습니다. Photos 앱과 iCloud Photos 설정에 따라 사용자가 관리합니다.</li>
                <li><strong>구매 상태:</strong> Apple과 RevenueCat이 구매 복원 및 법적 의무에 필요한 범위에서 보관합니다.</li>
                <li><strong>분석 이벤트:</strong> 분석이 활성화된 경우 서비스 구성의 보관 기간 동안 유지하며, 운영 목적에 필요하지 않게 되면 삭제 또는 집계합니다.</li>
                <li><strong>지원 이메일:</strong> 요청 처리와 후속 분쟁 대응에 필요한 기간 보관한 뒤 삭제합니다.</li>
              </ul>
              <p>앱을 삭제하면 로컬 주간 기록이 사라질 수 있지만 App Store의 비소모성 구매 기록은 같은 Apple ID에서 구매 복원이 가능할 수 있습니다. 구매 복원은 앨범 데이터 복원을 뜻하지 않습니다.</p>
            </section>

            <section className="document-section" id="rights">
              <h2>6. 사용자의 선택과 권리</h2>
              <ul>
                <li>iOS 설정에서 사진 접근을 전체, 제한, 거부로 언제든 변경할 수 있습니다.</li>
                <li>iOS 설정에서 Weekkeep의 로컬 알림을 끌 수 있습니다.</li>
                <li>앱 삭제로 Weekkeep 로컬 기록을 제거할 수 있습니다.</li>
                <li>외부 서비스가 처리한 데이터의 열람·정정·삭제·처리 제한 문의는 아래 이메일로 요청할 수 있습니다. 요청 확인을 위해 최소한의 추가 정보가 필요할 수 있습니다.</li>
              </ul>
              <h3>어린이의 개인정보</h3>
              <p>Weekkeep은 부모·보호자가 자신의 기기에서 사용하도록 설계됐으며 어린이가 계정을 만들거나 정보를 직접 제출하는 서비스가 아닙니다. 사진에 어린이가 포함될 수 있으므로 사용자는 해당 사진을 처리할 적법한 권한을 확보해야 합니다.</p>
              <h3>보안</h3>
              <p>전송이 필요한 구매·분석·지원 데이터에는 암호화된 연결을 사용하고, 사진 관련 데이터는 외부 요청 스키마에서 차단합니다. 다만 어떤 기기나 전송 방식도 절대적인 보안을 보장할 수는 없습니다.</p>
            </section>

            <div className="language-divider" id="english">ENGLISH</div>

            <section className="document-section" lang="en">
              <h2>Privacy Policy — English summary</h2>
              <p>Weekkeep is designed for parents and guardians to create a small weekly photo record on their iPhone. Photo selection and share rendering are processed on your iPhone. Weekkeep does not send photo pixels, thumbnails, filenames, locations, capture timestamps, Photos identifiers, or other photo details to analytics services or other services for analysis. Sharing starts only when you choose it.</p>
              <h3>Information processed on your device</h3>
              <p>After you choose to start and grant Photos access, Weekkeep uses Apple Photos and Vision frameworks in the foreground to review permitted photos, estimate quality and similarity, and prepare up to seven choices. When you choose Share, Weekkeep renders the share image on your iPhone and opens Apple’s system share sheet. It stores the week range, selection order, local Photos references, replacement state, and reminder preferences in the app’s local container. It does not copy full photo files into its own backup.</p>
              <h3>Purchases and analytics</h3>
              <p>Apple processes App Store payments. RevenueCat may process an anonymous app user ID, product, transaction, and entitlement status when you purchase or restore Weekkeep Plus. If product analytics is enabled in a distributed build, Weekkeep sends only allowlisted, coarse product events to PostHog EU Cloud. Autocapture, person profiles, identification, session replay, surveys, feature flags, tracing, and automatic crash capture are disabled. Neither vendor receives photo data from Weekkeep.</p>
              <h3>Storage, deletion, and your choices</h3>
              <p>Weekkeep has no account, Weekkeep cloud backup, CloudKit sync, or cross-device album restore. Local records can be lost if you delete the app, change devices, delete source photos, or revoke access. Original photos remain under your control in Photos. You can change Photos and notification permissions in iOS Settings and remove local Weekkeep records by deleting the app. Restoring Plus restores purchase access, not album data.</p>
              <h3>No tracking or sale</h3>
              <p>Weekkeep does not use advertising, cross-app or cross-site tracking, biometric identity recognition, or the sale of personal information.</p>
              <p>The detailed Korean sections above describe the categories, purposes, service providers, retention, and user controls. If a translated provision conflicts, the version most protective of the user will guide our interpretation unless applicable law requires otherwise.</p>
            </section>

            <section className="document-section" id="contact">
              <h2>7. 변경과 문의 / Changes and contact</h2>
              <p>중요한 처리 방식이 바뀌면 시행일과 내용을 이 페이지에 갱신하고 필요한 경우 앱 안에서 알립니다. Privacy questions, access, or deletion requests can be sent to:</p>
              <p><strong>Weekkeep Privacy</strong><br /><a href="mailto:kimsol1134@gmail.com?subject=Weekkeep%20Privacy">kimsol1134@gmail.com</a></p>
            </section>
          </article>
        </div>
      </main>
    </SiteShell>
  );
}
