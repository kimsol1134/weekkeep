import assert from "node:assert/strict";
import test from "node:test";

async function render(pathname = "/") {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}-${pathname}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request(`http://localhost${pathname}`, {
      headers: { accept: "text/html" },
    }),
    {
      ASSETS: {
        fetch: async () => new Response("Not found", { status: 404 }),
      },
    },
    {
      waitUntil() {},
      passThroughOnException() {},
    },
  );
}

const routes = [
  ["/", "사진은 많은데", "A week worth keeping"],
  ["/privacy", "사진은 추억이고", "Privacy Policy"],
  ["/terms", "이용약관", "Terms of Use"],
  ["/support", "막히는 순간이 없도록", "Help &amp; Support"],
];

for (const [pathname, visibleCopy, title] of routes) {
  test(`server-renders ${pathname}`, async () => {
    const response = await render(pathname);
    assert.equal(response.status, 200);
    assert.match(response.headers.get("content-type") ?? "", /^text\/html\b/i);

    const html = await response.text();
    assert.match(html, new RegExp(visibleCopy));
    assert.match(html, new RegExp(`<title>${title}`));
    assert.match(html, /Weekkeep/);
    assert.match(html, /href="\/privacy"/);
    assert.match(html, /href="\/terms"/);
    assert.match(html, /href="\/support"/);
    assert.doesNotMatch(html, /Your site is taking shape|Building your site|react-loading-skeleton/);
  });
}

test("renders the canonical wordmark in the header and footer", async () => {
  const response = await render("/");
  const html = await response.text();
  const header = html.match(/<header\b[^>]*>[\s\S]*?<\/header>/)?.[0];
  const footer = html.match(/<footer\b[^>]*>[\s\S]*?<\/footer>/)?.[0];
  const logoUrl = /src="\/brand\/weekkeep-wordmark\.png"/;

  assert.ok(header, "header should be rendered");
  assert.ok(footer, "footer should be rendered");
  assert.match(header, logoUrl);
  assert.match(footer, logoUrl);
  assert.equal((html.match(/src="\/brand\/weekkeep-wordmark\.png"/g) ?? []).length, 2);
  assert.equal((html.match(/class="brand-wordmark"/g) ?? []).length, 2);
  assert.match(html, /width="1400"[^>]*height="360"|height="360"[^>]*width="1400"/);
  assert.match(html, /alt=""/);
  assert.doesNotMatch(html, /class="brand-word"/);
});

test("renders the flat seven-photo story without the legacy album mockup", async () => {
  const response = await render("/");
  const html = await response.text();

  assert.match(html, /class="photo-story"/);
  assert.match(html, /class="photo-story-grid"/);
  const fixturePaths = [
    ...html.matchAll(/src="(\/fixtures\/app-store-family-moments\/[^"?]+)"/g),
  ].map((match) => match[1]);
  assert.equal(new Set(fixturePaths).size, 7);
  assert.match(html, /src="\/brand\/weekkeep-wordmark\.png"/);
  assert.doesNotMatch(html, /keepsake-cover|keepsake-visual|7 moments/);
});

test("privacy and terms disclose local-only storage boundaries", async () => {
  const [privacyResponse, termsResponse] = await Promise.all([
    render("/privacy"),
    render("/terms"),
  ]);
  const privacy = await privacyResponse.text();
  const terms = await termsResponse.text();

  assert.match(privacy, /RevenueCat/);
  assert.match(privacy, /PostHog EU Cloud/);
  assert.match(privacy, /사진 픽셀/);
  assert.match(terms, /구매 복원은 기능 접근만 복원/);
  assert.match(terms, /Standard Licensed Application End User License Agreement/);
});
