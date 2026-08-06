import assert from "node:assert/strict";
import test from "node:test";

const cdpBaseURL = process.env.WK_SITE_CDP_URL;
const targetURL = process.env.WK_SITE_BOUNDS_URL ?? "http://localhost:3001/";
const viewportWidth = Number(process.env.WK_SITE_BOUNDS_WIDTH ?? 390);
const viewportHeight = Number(process.env.WK_SITE_BOUNDS_HEIGHT ?? 844);

test(
  "mobile hero and photo story stay inside the viewport",
  { skip: !cdpBaseURL ? "set WK_SITE_CDP_URL to a local Chrome CDP endpoint" : false },
  async () => {
    const targets = await (await fetch(`${cdpBaseURL}/json/list`)).json();
    const page = targets.find((target) => target.type === "page");
    assert.ok(page?.webSocketDebuggerUrl, "a local CDP page target is required");

    const socket = new WebSocket(page.webSocketDebuggerUrl);
    let nextID = 0;
    const pending = new Map();
    socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      const resolve = pending.get(message.id);
      if (resolve) {
        pending.delete(message.id);
        resolve(message);
      }
    });
    await new Promise((resolve, reject) => {
      socket.addEventListener("open", resolve, { once: true });
      socket.addEventListener("error", reject, { once: true });
    });

    const cdp = (method, params = {}) =>
      new Promise((resolve) => {
        const id = ++nextID;
        pending.set(id, resolve);
        socket.send(JSON.stringify({ id, method, params }));
      });

    try {
      await cdp("Page.enable");
      await cdp("Runtime.enable");
      await cdp("Emulation.setDeviceMetricsOverride", {
        width: viewportWidth,
        height: viewportHeight,
        deviceScaleFactor: 1,
        mobile: false,
      });
      await cdp("Page.navigate", { url: targetURL });
      await new Promise((resolve) => setTimeout(resolve, 900));

      const result = await cdp("Runtime.evaluate", {
        returnByValue: true,
        awaitPromise: true,
        expression: `(() => {
          const selectors = [
            ".site-header",
            ".hero h1",
            ".hero-lead",
            ".status-pill",
            ".text-link",
            ".photo-story-visual",
            ".photo-story",
            ".photo-story-grid",
            ".photo-story-tile",
          ];
          const readBounds = (selector) => {
            const node = document.querySelector(selector);
            if (!node) return null;
            const box = node.getBoundingClientRect();
            const range = document.createRange();
            range.selectNodeContents(node);
            const textRects = Array.from(range.getClientRects()).map((rect) => ({
              left: rect.left,
              right: rect.right,
              top: rect.top,
              bottom: rect.bottom,
            }));
            return {
              selector,
              box: { left: box.left, right: box.right, top: box.top, bottom: box.bottom },
              textRects,
            };
          };
          return {
            viewport: { width: innerWidth, height: innerHeight },
            bounds: selectors.map(readBounds).filter(Boolean),
          };
        })()`,
      });
      const value = result?.result?.result?.value;
      assert.deepEqual(value?.viewport, { width: viewportWidth, height: viewportHeight });
      assert.equal(value?.bounds?.length, 9);

      for (const item of value.bounds) {
        assert.ok(item.box.left >= -0.5, `${item.selector} left bound escaped viewport`);
        assert.ok(item.box.right <= viewportWidth + 0.5, `${item.selector} right bound escaped viewport`);
        assert.ok(item.box.top >= -0.5, `${item.selector} top bound escaped viewport`);
        for (const rect of item.textRects) {
          assert.ok(rect.left >= -0.5, `${item.selector} text left bound escaped viewport`);
          assert.ok(rect.right <= viewportWidth + 0.5, `${item.selector} text right bound escaped viewport`);
        }
      }
    } finally {
      socket.close();
    }
  },
);
