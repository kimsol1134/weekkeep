import type { Metadata } from "next";
import { SiteShell } from "../components/SiteShell";

export const metadata: Metadata = {
  title: "Terms of Use",
  description: "Terms governing use of the Weekkeep iPhone app and Weekkeep Plus.",
};

export default function TermsPage() {
  return (
    <SiteShell>
      <main>
        <header className="document-hero section-pad">
          <p className="eyebrow">TERMS OF USE</p>
          <h1>Weekkeep<br />이용약관</h1>
          <p className="lede">
            Weekkeep은 사진을 대신 보관하는 클라우드가 아니라, 사용자의 iPhone
            안에서 한 주를 고르고 남기는 도구입니다. 사용 전에 서비스 범위와
            로컬 저장의 한계를 확인해 주세요.
          </p>
          <div className="document-meta">
            <span>시행일 / Effective: 2026-08-05</span>
            <span>운영자 / Operator: Weekkeep (김솔 / Sol Kim)</span>
          </div>
        </header>

        <div className="document-layout section-pad">
          <nav className="document-nav" aria-label="Terms sections">
            <strong>CONTENTS</strong>
            <a href="#agreement">동의와 자격</a>
            <a href="#service">서비스 범위</a>
            <a href="#local-data">로컬 데이터</a>
            <a href="#plus">Weekkeep Plus</a>
            <a href="#use">허용되는 사용</a>
            <a href="#warranty">책임과 보증</a>
            <a href="#english">English</a>
            <a href="#contact">문의</a>
          </nav>

          <article className="document-body">
            <section className="document-section" id="agreement">
              <h2>1. 동의와 이용 자격</h2>
              <p>Weekkeep 앱 또는 이 웹사이트를 사용하면 본 약관과 <a href="/privacy">개인정보 처리방침</a>에 동의하는 것으로 봅니다. 동의하지 않으면 앱을 사용하지 마세요.</p>
              <p>Weekkeep은 부모·보호자 등 자신의 사진 라이브러리를 적법하게 관리할 수 있는 사용자를 위한 앱입니다. 미성년자는 법정대리인의 허락과 감독 아래에서만 사용해야 합니다. 사용자는 앱에 접근시키는 사진을 처리하고 볼 권한이 있음을 보장합니다.</p>
            </section>

            <section className="document-section" id="service">
              <h2>2. 서비스와 라이선스</h2>
              <p>Weekkeep은 최근 완료된 주간의 허용된 사진을 기기에서 분석해 최대 7장의 초안을 제안하고, 사용자가 검토·교체·저장하도록 돕습니다. 결과는 자동 추천이며 사진의 중요도나 품질을 객관적으로 보증하지 않습니다.</p>
              <p>본 약관을 지키는 동안 Weekkeep은 사용자의 개인적·비상업적 사용을 위한 제한적이고, 비독점적이며, 양도할 수 없고, 취소 가능한 앱 사용 권한을 부여합니다. 앱과 브랜드, 코드, 디자인에 대한 소유권은 운영자와 해당 라이선스 제공자에게 있습니다. 사용자의 원본 사진 소유권은 사용자에게 남습니다.</p>
              <p>iOS 앱 사용에는 Apple의 <a href="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/" rel="noreferrer">Standard Licensed Application End User License Agreement</a>도 적용됩니다. 본 약관과 Apple 표준 EULA가 충돌하면 법령과 Apple 요구사항이 허용하는 범위에서 Apple 표준 EULA가 우선합니다.</p>
            </section>

            <section className="document-section" id="local-data">
              <h2>3. 사진 권한과 로컬 데이터</h2>
              <ul>
                <li>사진 접근과 알림 권한은 선택 사항이지만, 사진 접근 없이는 핵심 앨범 생성 기능을 사용할 수 없습니다.</li>
                <li>Weekkeep은 계정, 자체 클라우드 백업, CloudKit 동기화, 기기 간 앨범 복원을 제공하지 않습니다.</li>
                <li>저장 기록은 Photos의 원본 자산을 참조합니다. 원본 삭제, 접근 권한 변경, 앱 삭제, 기기 분실·변경·고장, 운영체제 또는 저장소 문제로 기록이 사라지거나 표시되지 않을 수 있습니다.</li>
                <li>중요한 사진은 Photos/iCloud Photos 또는 사용자가 선택한 별도 백업 수단으로 직접 보관해야 합니다.</li>
              </ul>
              <div className="notice"><p><strong>Weekkeep Plus 구매 복원은 기능 접근만 복원합니다.</strong> 이전 기기의 주간 앨범이나 사진 참조를 복원하지 않습니다.</p></div>
            </section>

            <section className="document-section" id="plus">
              <h2>4. Weekkeep Plus와 결제</h2>
              <p>Weekkeep은 일정 수의 무료 주간 기록 이후 추가 기록 생성을 위해 Plus를 제안할 수 있습니다. Plus Lifetime은 App Store의 비소모성 일회성 구매 상품이며, 구매 화면에 표시되는 현지화 가격과 세금이 적용됩니다.</p>
              <ul>
                <li>결제는 Apple ID에 연결된 App Store 결제 수단으로 Apple이 처리합니다.</li>
                <li>같은 Apple ID와 지원되는 App Store 환경에서 구매 복원을 시도할 수 있습니다.</li>
                <li>환불과 결제 분쟁은 Apple의 정책 및 절차를 따르며 Weekkeep이 직접 승인하지 않습니다.</li>
                <li>“Lifetime”은 구매 시 지원되는 Weekkeep Plus 기능에 대한 비소모성 라이선스를 뜻하며, 앱이나 특정 기능의 영구 제공, 무제한 지원, 기기 호환성, 사진·앨범 데이터의 영구 보존을 보장하지 않습니다.</li>
                <li>법령, App Store 정책, 보안 또는 기술적 사유로 기능을 변경하거나 서비스를 종료해야 하는 경우 합리적인 사전 고지를 위해 노력합니다.</li>
              </ul>
            </section>

            <section className="document-section" id="use">
              <h2>5. 허용되는 사용</h2>
              <p>사용자는 관련 법령, 타인의 초상권·저작권·개인정보 권리를 지켜야 합니다. 다음 행위를 해서는 안 됩니다.</p>
              <ul>
                <li>앱 보안, 구매 확인, 사용 제한을 우회하거나 방해하는 행위</li>
                <li>법이 허용하는 범위를 넘어 앱을 복제, 재판매, 역설계 또는 자동화된 방식으로 악용하는 행위</li>
                <li>타인의 기기나 사진에 권한 없이 접근하는 행위</li>
                <li>서비스, Apple, RevenueCat, PostHog 또는 다른 사용자에게 손해를 주는 악성 행위</li>
              </ul>
              <p>중대한 위반, 보안 위험 또는 법적 의무가 있으면 앱 기능이나 지원을 제한할 수 있습니다. 로컬 전용 앱의 특성상 운영자가 사용자의 기기 내 사진이나 앨범을 원격으로 열람하거나 삭제하지는 않습니다.</p>
            </section>

            <section className="document-section" id="warranty">
              <h2>6. 가용성, 보증과 책임</h2>
              <p>Weekkeep은 관련 법이 허용하는 최대 범위에서 “있는 그대로” 및 “사용 가능한 상태로” 제공됩니다. 특정 사진이 선택될 것, 무오류·무중단 작동, 모든 기기·OS와의 호환, 데이터 보존을 보증하지 않습니다.</p>
              <p>관련 법이 허용하는 범위에서 운영자는 간접적·우발적·특별·결과적 손해, 사진 또는 기록 손실, 이익 손실에 책임을 지지 않습니다. 운영자의 총 책임은 청구 원인이 발생하기 전 12개월 동안 사용자가 Weekkeep에 실제 지급한 금액을 넘지 않습니다. 다만 고의·중과실 또는 법률상 제한할 수 없는 소비자 권리는 제외합니다.</p>
              <h3>변경과 종료</h3>
              <p>제품, 법령 또는 App Store 요구사항이 바뀌면 약관을 갱신할 수 있습니다. 중요한 변경은 시행일을 갱신하고 합리적인 방식으로 알립니다. 사용자는 언제든 앱 사용을 중단하고 삭제할 수 있습니다.</p>
              <h3>준거법</h3>
              <p>강행 소비자보호법이 달리 정하지 않는 한 대한민국 법을 따릅니다. 분쟁이 발생하면 먼저 이메일로 해결을 시도하고, 해결되지 않으면 관련 법령상 관할 법원에서 다룹니다.</p>
            </section>

            <div className="language-divider" id="english">ENGLISH</div>

            <section className="document-section" lang="en">
              <h2>Terms of Use — English</h2>
              <h3>Agreement and eligibility</h3>
              <p>By using Weekkeep, you agree to these Terms and the <a href="/privacy">Privacy Policy</a>. Weekkeep is intended for parents, guardians, and others who have the lawful right to manage the photos they permit the app to access. Minors may use it only with a parent or guardian’s permission and supervision.</p>
              <h3>Service and license</h3>
              <p>Weekkeep uses on-device processing to suggest up to seven photos from a recently completed week for your review. Suggestions are subjective and are not a promise that any particular photo is important or high quality. You receive a limited, non-exclusive, non-transferable, revocable license for personal, non-commercial use. You retain ownership of your photos.</p>
              <p>Apple’s <a href="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/" rel="noreferrer">Standard EULA</a> also applies to the iOS app and controls where required by Apple or applicable law.</p>
              <h3>Local storage limitation</h3>
              <p>Weekkeep does not provide an account, a Weekkeep cloud backup, CloudKit sync, or cross-device album restore. Records can be lost or become unavailable if you delete the app, change or lose your device, delete source photos, revoke Photos access, or encounter storage or operating-system failure. Keep important originals backed up using Photos, iCloud Photos, or another service you choose.</p>
              <h3>Weekkeep Plus</h3>
              <p>Plus Lifetime is a one-time, non-consumable App Store purchase. Apple handles payment, localized pricing, tax, and refunds. Restore Purchases may restore feature access for the same Apple ID in a supported environment; it does not restore weekly album data. “Lifetime” does not guarantee permanent operation of the app, indefinite support, perpetual device compatibility, or permanent storage of any photo or record.</p>
              <h3>Acceptable use and warranty</h3>
              <p>You may not bypass security or purchase controls, unlawfully access another person’s device or photos, infringe intellectual-property or privacy rights, or misuse the app. To the maximum extent permitted by law, Weekkeep is provided “as is” without a promise of uninterrupted operation, compatibility, selection accuracy, or data preservation. Liability limitations do not exclude rights that cannot lawfully be limited, including liability for willful misconduct or gross negligence where applicable.</p>
              <h3>Changes, termination, and law</h3>
              <p>We may update the app or these Terms for product, legal, security, or App Store reasons and will use reasonable efforts to give notice of material changes. You may stop using and delete the app at any time. Unless mandatory consumer law provides otherwise, these Terms are governed by the laws of the Republic of Korea.</p>
            </section>

            <section className="document-section" id="contact">
              <h2>7. 문의 / Contact</h2>
              <p>약관이나 결제 지원에 관한 문의는 <a href="mailto:kimsol1134@gmail.com?subject=Weekkeep%20Terms">kimsol1134@gmail.com</a>으로 보내주세요.</p>
            </section>
          </article>
        </div>
      </main>
    </SiteShell>
  );
}
