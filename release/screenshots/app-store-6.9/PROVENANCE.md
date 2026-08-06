# App Store 6.9-inch screenshot provenance

This directory contains the six-screen App Store composition for each locale, regenerated for `1.0.0 (3)` on 2026-08-06. The corrected build-3 screenshot set was uploaded to App Store Connect, replaced the prior en-US/ko `APP_IPHONE_67` sets, and was re-read as six `COMPLETE` assets per locale at `1320×2868`. The prior build-2 screenshot evidence remains historical.
The raw app captures are recorded in the manifest's locale-specific source paths and are ignored by git.

- Device: Weekkeep AppStore 6.9 (`9C794F17-634B-4B7A-86A9-AEE88EE575FF`), iOS 26.5
- Output: two locales × six opaque JPEGs, exactly `1320×2868`
- Composition: Cream `#FBF7F2`, Plum `#5B415E`, Linen `#E8E1DB`, no device frame
- Headline font: bundled `LINESeedSansKR-Bold`
- Capture mode: DEBUG bundled-fixture XCTest UI evidence via `-ui-app-store-fixtures`; it does not exercise PhotoKit.
- Fixture policy: the seven fictional, non-identifiable images below are the bundled `SamplePhotoFixtures`; they are not customer photos.
- Real PhotoKit behavior is validated separately through the live adapter/device QA path.

## Approved fixture sources

- `design/fixtures/app-store-family-moments/01-ginkgo-leaf.png` — SHA-256 `5caa8f0beb6c6f3f7e18f5892516b07eeeeccdc780fc6bed495fc86556927e5d`
- `design/fixtures/app-store-family-moments/02-pancake-morning.png` — SHA-256 `18e1d3051fbe044b1c3001970c2c4a88d133308ee4fcf9cb34c9a5ee4280abdb`
- `design/fixtures/app-store-family-moments/03-rainy-puddle.png` — SHA-256 `c392ebc057888e6a27974b3c823003d53c3cf99c1a2a9c8e8708d48a856d53c5`
- `design/fixtures/app-store-family-moments/04-bedtime-story.png` — SHA-256 `e528e538c7e053df523acf19d64ed6388349f27bce767ec2ef4b73bbe939a6c4`
- `design/fixtures/app-store-family-moments/05-park-bubbles.png` — SHA-256 `74e5c26843eeeb6ccf7dea55357676674b799d0cde3ec70508ac217a19cce8b1`
- `design/fixtures/app-store-family-moments/06-acorn-home.png` — SHA-256 `698cb80f89dbb184340f652c475d48c9730a9842fe2c22ee7502985ac94b3be0`
- `design/fixtures/app-store-family-moments/07-balcony-herbs.png` — SHA-256 `276f8db9c6133f44aa3397857277510116ba5f26657871f917d1b6ec6331f86e`

## Final screenshot hashes

### en-US

- `01-welcome.jpg` — Your week, already waiting. — SHA-256 `3f77dcda6edfef024f93bb80cf4d2d3a7c690ed8fcd86f45409dae501c599e1c`
- `02-curation-progress.jpg` — Private from the first tap. — SHA-256 `12d941e2509dd1a90d9cd9acf06a5b5bcffdb5b512be4a26767c4f2eb235e8e1`
- `03-review.jpg` — Seven moments. Nothing to sort. — SHA-256 `fff9a3e5e72264cc4333057fd51317687076e27419ef163c2eec7f051c065992`
- `04-replace.jpg` — Change one. Keep the feeling. — SHA-256 `4e4d1d6563d6391dcf601deedc563feeae56a4b787377ed7f7e74f4d2968d252`
- `05-saved-weeks.jpg` — A small album, every week. — SHA-256 `0d2135b950d303d585031df2cde07c9663fdc1df5907556d0704915b4d8c49a3`
- `06-plus.jpg` — Two albums free. Then yours for life. — SHA-256 `f1c6bf36e366c2cfad3f921e8461a1c098dca309fa39520fd26727c26a5081c2`

### ko

- `01-welcome.jpg` — 사진은 많고, 시간은 없으니까. — SHA-256 `3fbe9451ea78f0cb760ad3abbafb8c29a1d8945c53650bd55bca66e61fa7815f`
- `02-curation-progress.jpg` — 첫 탭부터, 사진은 기기 안에서. — SHA-256 `6b80f80bf2c079617b743d81ef329b81e8bb7a3649d1b9db299b6e301e8f5427`
- `03-review.jpg` — 일주일에 7장만. — SHA-256 `ebaa9256b3f03807b802ba91e919b9d4dc15e487767bc99c2e5ca93d3432632a`
- `04-replace.jpg` — 마음에 안 드는 한 장만 바꾸세요. — SHA-256 `d5087a52695599197b6d13c2e739d9cbe10d174c926264b80914cf356bd2addd`
- `05-saved-weeks.jpg` — 작은 한 주가 차곡차곡. — SHA-256 `94da7a6e08aa6a50ad7ba39f4ca58a8c4f5af421d972a762600056668cd52ce0`
- `06-plus.jpg` — 두 번 무료, 그다음은 평생 이용권. — SHA-256 `d7fe9b56ed288a9a5fcd124bc1ddd90a4203cd88fc915fddbd2b2badbdfbfa17`
