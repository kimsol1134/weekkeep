import type { ReactNode } from "react";
import Link from "next/link";
import { SevenStitches } from "./SevenStitches";

export function SiteShell({ children }: { children: ReactNode }) {
  return (
    <div className="site-shell">
      <header className="site-header">
        <Link className="brand" href="/" aria-label="Weekkeep home">
          <img
            className="brand-wordmark"
            src="/brand/weekkeep-wordmark.png"
            width={1400}
            height={360}
            alt=""
          />
          <SevenStitches compact />
        </Link>
        <nav className="site-nav" aria-label="Main navigation">
          <Link href="/privacy">Privacy</Link>
          <Link href="/terms">Terms</Link>
          <Link href="/support">Support</Link>
        </nav>
      </header>

      {children}

      <footer className="site-footer">
        <div>
          <Link className="brand brand--footer" href="/" aria-label="Weekkeep home">
            <img
              className="brand-wordmark"
              src="/brand/weekkeep-wordmark.png"
              width={1400}
              height={360}
              alt=""
            />
            <SevenStitches compact />
          </Link>
          <p>아이와 보낸 일주일, 최대 7장으로 남겨요.</p>
        </div>
        <nav aria-label="Footer navigation">
          <Link href="/privacy">개인정보 처리방침</Link>
          <Link href="/terms">이용약관</Link>
          <Link href="/support">도움말 및 문의</Link>
          <a href="mailto:kimsol1134@gmail.com">이메일</a>
        </nav>
        <p className="copyright">© 2026 Weekkeep · Made with care in Seoul</p>
      </footer>
    </div>
  );
}
