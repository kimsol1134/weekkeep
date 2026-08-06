---
format: 1920x1080
duration: 72s
message: "Parents do not need another daily habit; Weekkeep turns one private minute a week into a seven-photo family album they can keep and share."
arc: "Demo Loop — outcome → product → trust → review → edit → save/share → revisit → settings → Plus → brand"
audience: shipaton judges and parents
mode: autonomous
music: quiet warm acoustic-electronic underscore, gentle weekly pulse, no vocals, restrained family documentary
captions: full English narration
---

## Video direction

- palette system: Use only the approved Weekkeep roles from `frame.md`: Cream `#FBF7F2` for the primary field, Ink `#25212B` for copy, Plum `#5B415E` for brand structure, Sage `#537763` for privacy/local reassurance, Coral `#E97A68` for parent choice, Gold `#E5A84B` for a single warm payoff, and the approved muted seven-stitch rainbow only when the full weekly rhythm is visible. Never substitute brown, neon, pure black, or pure white.
- type system: Use the display, body, and utility roles from `frame.md`; hierarchy comes from scale, weight, and placement rather than extra fonts. Keep all essential content inside the top 83% caption-safe area.
- motion grammar: One paused, deterministic GSAP timeline per frame. Use smooth long-tail `power3`-class settles, explicit `fromTo` entrances, and VO-paced sequential reveals across the back half of each shot. No content appears before the narration names it. Between-frame exits belong to the harness transitions already specified.
- camera grammar: The phone/app surface is the evidence. Camera moves are rare and purposeful: Frame 1 owns the single outward reveal; Frames 2, 4, 5, 6, 8, and 9 lock the camera after establishing the surface; Frames 3 and 7 stay symmetric and static; Frame 10 is an element-level brand assembly.
- rhythm: Frames 3 and 6 are deliberate breathers, Frame 7 ends on a peaceful held read, and Frame 10 holds the completed lockup. Other frames develop on spoken cues and settle before their final second. During holds prefer complete stillness; at most one finite, low-amplitude stitch jitter may remain alive.
- asset discipline: Use only the listed `asset_candidates`. Screenshots stay legible and materially unaltered; crops, masks, focus treatments, and callouts may direct attention but must not fabricate product state. All photo content is the approved synthetic fixture set.
- negative list: No floating bokeh, generic purple-blue AI gradients, glassmorphism as decoration, browser chrome, real cursor, fake upload/cloud animation, subscription language, unsupported analytics claims, slideshow front-load-then-freeze, screensaver motion, lazy breathing, back-half camera drift, bounce chains, infinite loops, randomness, or wall-clock animation.

## Frame 1 — One quiet minute

- scene: Begin inside one saved moment, then reveal the full seven-photo weekly album and the promise.
- voiceover: "Parents don't need another app to open every day. They need one quiet minute to keep the week."
- duration: 6s
- poster: 6s
- transition_in: cut
- status: animated
- src: compositions/frames/01-one-quiet-minute.html
- type: hook
- persuasion: Pain relief through a concrete alternative
- beat: recognition → relief
- blueprint: zoom-out-workspace-reveal
- asset_candidates: assets/04-save-confirmation.jpg — saved seven-photo album and emotional payoff
- focal: assets/04-save-confirmation.jpg
- roles: 04-save-confirmation = cutout hero and final evidence
- sfx: whoosh-short

Adapt: keep the single decelerating zoom-out and post-lock payoff; replace a software workspace with the real saved Weekkeep album nested inside a restrained Cream editorial field. No zoom-in or second camera move.
Scene 1 (0.0–1.7s): open extremely tight on one saved fixture-photo stitch inside `04-save-confirmation`, full-bleed with no phone chrome; the small line “Not another daily habit.” reveals only as the VO says “every day.” Layered-depth macro, one focal crop, Ink on Cream; the screenshot remains the only evidence.
Scene 2 (1.7–4.1s): ONE continuous decelerating zoom-out (`viewport-change`, target-to-wide) reveals the complete saved seven-photo confirmation inside a large portrait surface, then the surrounding Cream field and seven muted stitch marks resolve around it as the VO reaches “one quiet minute.” Asymmetric 60/40, three depth layers; the pull stops completely at 4.1s.
Scene 3 (4.1–6.0s): camera locked. The payoff line “One quiet minute a week.” reveals word-group by word-group (`dynamic-content-sequencing`) in the open right column; a thin Plum rule finishes beneath “a week,” then the complete composition holds still through the cut. Primary visual remains over 40% of canvas; caption band stays clear.

narrativeRole: State the parent-centered value before naming features or technology.
keyMessage: The product asks for one calm weekly minute, not daily engagement.

## Frame 2 — Meet Weekkeep

- scene: The approved app icon and onboarding surface introduce the one-week, seven-moment product loop.
- voiceover: "Weekkeep turns a crowded camera roll into up to seven family moments worth keeping."
- duration: 6s
- poster: 8s
- transition_in: zoom-through
- status: animated
- src: compositions/frames/02-meet-weekkeep.html
- type: product_intro
- persuasion: Friction reduction
- beat: curiosity → clarity
- blueprint: device-surface-showcase
- asset_candidates: assets/01-welcome.jpg — English onboarding and local-photo trust message; assets/weekkeep-app-icon.png — approved exact-seven app icon
- focal: assets/01-welcome.jpg
- roles: 01-welcome = cutout hero surface; weekkeep-app-icon = supporting brand anchor
- sfx: pop

Adapt: use the static-tour variant; keep one persistent product surface and sequential on-face emphasis, but replace screen cycling with a truthful onboarding reveal plus the approved icon. Camera stays locked after the establish.
Scene 1 (0.0–1.3s): on a Cream field, the approved app icon arrives left-of-center with a smooth scale settle (`spring-pop-entrance`, no overshoot) while the word “Weekkeep” reveals beside it as the VO names the product. Centered-to-asymmetric 40/60, three depth layers, Plum structure.
Scene 2 (1.3–3.5s): `01-welcome` slides into the right hero position as a tall clean device surface; the icon reduces to a quiet upper-left anchor. The onboarding headline and local-photo promise remain crisp while a short Coral underline appears on the spoken phrase “crowded camera roll.” No cursor and no fabricated UI state.
Scene 3 (3.5–5.1s): seven muted stitch marks reveal left-to-right (`center-outward-expansion`, short-path form) only as the VO reaches “up to seven”; the words “up to” stay visibly attached to the number so seven never reads as a quota. The device remains static and dominant.
Scene 4 (5.1–6.0s): a compact line, “family moments worth keeping,” resolves below the stitch rail via per-word reveal (`dynamic-content-sequencing`); icon, line, and real onboarding surface hold in a balanced editorial composition with no camera drift.

narrativeRole: Name the product and translate its mechanism into the parent's desired outcome.
keyMessage: A crowded week becomes at most seven moments worth keeping.

## Frame 3 — Trust before access

- scene: The privacy explanation arrives before access, beside an on-device analysis boundary diagram.
- voiceover: "Photos access is requested only after this explanation. Analysis runs here, on the iPhone; photo content and identifiers are not uploaded."
- duration: 11.5s
- poster: 10s
- transition_in: crossfade
- status: animated
- src: compositions/frames/03-trust-before-access.html
- type: feature_showcase
- persuasion: Risk reversal with an explicit boundary
- beat: skepticism → trust
- blueprint: comparison-split
- asset_candidates: assets/10-privacy-primer.jpg — exact privacy explanation; assets/01-welcome.jpg — local-photo trust message before the core action
- focal: assets/10-privacy-primer.jpg
- roles: 10-privacy-primer = left cutout and primary proof; 01-welcome = right supporting cutout and sequence context
- sfx: whoosh-short

Adapt: keep the mirrored opposite-wing split and inner-edge badges; stretch the final hold to let the exact privacy boundary read. The pair represents sequence, not competing alternatives: explanation first, access second.
Scene 1 (0.0–2.1s): only the centered title “Trust before access” slides down into the upper third (`gsap-effects`, long-tail settle) as the VO introduces the explanation. Cream field, Ink title, a short Sage rule; the lower canvas remains intentionally empty.
Scene 2 (2.1–5.3s): `10-privacy-primer` enters from the left and `01-welcome` from the right a beat later as equal portrait cards with mirrored restrained `rotateY` tilts (`split-tilt-cards`). A small directional label between them reads “explain → request,” appearing only when the VO reaches “only after.” Split-screen symmetry, three depth layers, outward shadows.
Scene 3 (5.3–8.5s): two attached inner-edge pills land sequentially: “ON DEVICE” in Sage on the left, then “NO PHOTO UPLOAD” in Plum on the right (`spring-pop-entrance`, critically damped). A thin boundary line draws between the cards (`svg-path-draw`) as “on the iPhone” and “not uploaded” are spoken.
Scene 4 (8.5–11.5s): the pair settles fully static. The exact bottom line “Photo content + identifiers stay on this iPhone.” reveals beneath the cards and holds long enough to read; no floating, breathing, or camera motion.

narrativeRole: Earn permission by showing the privacy promise before the Photos prompt.
keyMessage: Photo pixels and identifiers remain on the iPhone.

## Frame 4 — Seven is a limit

- scene: Hold the real review surface while the seven-stitch rail and honest adaptive grid become the visual proof.
- voiceover: "A draft is already prepared. Seven is a limit, not a target—if the week has fewer usable photos, Weekkeep shows fewer."
- duration: 9s
- poster: 11s
- transition_in: push-slide LEFT
- status: animated
- src: compositions/frames/04-seven-is-a-limit.html
- type: feature_showcase
- persuasion: Show-don't-tell proof plus honesty
- beat: ease + confidence
- blueprint: device-surface-showcase
- asset_candidates: assets/02-review.jpg — real seven-photo review surface and save action
- focal: assets/02-review.jpg
- roles: 02-review = cutout hero surface and sole product-state evidence
- sfx: pop

Adapt: use the static-tour variant; keep the persistent review surface and on-face sequential emphasis. No screen is fabricated to demonstrate fewer-than-seven—honesty is communicated with an explicit “up to” callout while the real seven-item fixture remains visible.
Scene 1 (0.0–1.8s): `02-review` establishes center-left as a large portrait surface with a short smooth rise and settle; the label “Draft prepared” appears in the right column only when the VO says “already prepared.” Asymmetric 60/40, three depth layers, screenshot at least 48% of canvas.
Scene 2 (1.8–4.2s): a Plum focus outline travels once around the real review grid and seven muted stitch markers reveal along the right rail one at a time (`svg-path-draw` plus short-path `center-outward-expansion`). The grid itself does not move or recompose.
Scene 3 (4.2–6.6s): as the narration says “a limit, not a target,” the large word “7” resolves to “UP TO 7” through an in-place token swap (`discrete-text-sequence`); a Coral marker circle draws around “UP TO,” not around the number. Camera and device remain locked.
Scene 4 (6.6–9.0s): the honest rule “Fewer usable photos → fewer shown” reveals beneath the limit statement, followed by a Sage check. The Save action remains visibly available in the real screenshot; the final second is a still held read.

narrativeRole: Prove the core loop while separating the seven-photo maximum from a gamified target.
keyMessage: Weekkeep never invents missing moments just to fill seven slots.

## Frame 5 — The parent stays editor

- scene: One photo enters the Coral selected state; the rest stays still.
- voiceover: "The parent stays the editor. Keep the draft, or change only the moment that doesn't feel right."
- duration: 7s
- poster: 9s
- transition_in: push-slide LEFT
- status: animated
- src: compositions/frames/05-parent-stays-editor.html
- type: feature_showcase
- persuasion: Control without added workload
- beat: control + reassurance
- blueprint: cursor-ui-demo
- asset_candidates: assets/03-review-selected.jpg — Coral selection and replacement disclosure; assets/02-review.jpg — unchanged weekly draft
- focal: assets/03-review-selected.jpg
- roles: 02-review = starting state; 03-review-selected = same-geometry payoff
- sfx: click-soft

Adapt: locked static-stage tour; one custom cursor triggers a truthful before/after swap while the camera stays fixed.
Scene 1 (0.0–1.7s): `02-review` fills center; “The parent stays the editor.” reveals upper-left. A Plum cursor rests by one tile. Locked 60/40 frame.
Scene 2 (1.7–3.5s): the cursor presses that tile with one restrained ripple (`cursor-click-ripple`); cursor and target briefly compress together (`physics-press-reaction`) while every other tile stays still.
Scene 3 (3.5–5.4s): at the click threshold, `02-review` scale-swaps at identical geometry to `03-review-selected` (`scale-swap-transition`). The real Coral state glows briefly (`asr-keyword-glow`) on “change only.”
Scene 4 (5.4–7.0s): “Only this moment” connects to Coral; “The rest stays put.” reveals below. Cursor parks; hold still.

narrativeRole: Demonstrate that on-device suggestions never take authorship away from the parent.
keyMessage: Edit one uncertain moment instead of rebuilding the whole week.

## Frame 6 — Save and share the week

- scene: The review resolves into the real saved-album confirmation, then into the production-rendered 9:16 Story artifact.
- voiceover: "One tap saves a small weekly album locally."
- duration: 5s
- poster: 8s
- transition_in: zoom-through
- status: animated
- src: compositions/frames/06-save-the-week.html
- type: benefit_highlight
- persuasion: Immediate emotional payoff
- beat: relief → quiet triumph
- blueprint: titlecard-reveal
- asset_candidates: assets/04-save-confirmation.jpg — saved-on-iPhone confirmation; assets/11-weekly-share-story.jpg — production-rendered English Story artifact
- focal: assets/11-weekly-share-story.jpg
- roles: 04-save-confirmation = local-save proof; 11-weekly-share-story = branded share payoff
- sfx: click-soft, chime

Adapt: preserve the restrained reveal and long still hold, but make the product payoff complete: the real save confirmation yields to the real Story artifact. This is one continuous outcome, not a second feature tour.
Scene 1 (0.0–0.9s): on a quiet Plum field, the small centered line “One tap.” reveals with a restrained fade-and-scale settle (`scale-swap-transition`) as the VO says it. A single Coral press ring contracts underneath, then disappears; no product surface is visible yet.
Scene 2 (0.9–2.1s): a Cream rounded wipe reveals `04-save-confirmation` left of center as local-save proof. The card then settles slightly smaller without changing its content.
Scene 3 (1.8–3.1s): a Coral hairline draws from the saved card toward `11-weekly-share-story`; the Story artifact slides into the right hero position with the attached mono label “STORY · 9:16.” No destination or recipient is fabricated.
Scene 4 (3.1–5.0s): “Saved locally. Ready to share.” resolves below the pair. The Story artifact remains dominant and the full composition holds still through the cut.

narrativeRole: Cash the interaction sequence into a recognizable weekly album that stays private until the parent chooses to share it.
keyMessage: One tap turns the draft into a branded local album ready for native sharing.

## Frame 7 — Revisit without pressure

- scene: Weeks list and saved-week detail open side by side, with no streak counter or unfinished backlog.
- voiceover: "Each week stays easy to revisit, with no streak, backlog, or account."
- duration: 6s
- poster: 7s
- transition_in: crossfade
- status: animated
- src: compositions/frames/07-revisit-without-pressure.html
- type: benefit_highlight
- persuasion: Negative contrast against guilt mechanics
- beat: peace of mind
- blueprint: comparison-split
- asset_candidates: assets/05-weeks.jpg — calm Weeks archive with one honest record; assets/06-week-detail.jpg — saved week and local-device boundary
- focal: assets/05-weeks.jpg
- roles: 05-weeks = left cutout archive overview; 06-week-detail = right cutout saved-week proof
- sfx: whoosh-short

Adapt: keep the balanced split and badge punctuation; use the cards as overview → detail rather than A/B alternatives. Camera remains static and the final held read is a deliberate breather.
Scene 1 (0.0–1.0s): the title “Revisit, without pressure.” slides down to the upper third with a smooth settle. Only a faint Cream-to-Sage field and title are visible at first.
Scene 2 (1.0–2.9s): `05-weeks` and `06-week-detail` arrive from opposite wings with mirrored shallow tilts (`split-tilt-cards`), settling as equal portrait cards. A short arrow between inner edges clarifies archive → saved week without implying cloud sync.
Scene 3 (2.9–4.6s): three small inner-axis pills appear sequentially on the spoken cue—“NO STREAK,” “NO BACKLOG,” “NO ACCOUNT”—using critically damped pops (`spring-pop-entrance`). The first is Coral, second Gold, third Sage, each muted to the approved palette.
Scene 4 (4.6–6.0s): the cards and pills settle into total stillness; the bottom line “Just the weeks you chose to keep.” wipes in left-to-right and holds within the caption-safe region.

narrativeRole: Show that the archive remains useful without turning memory keeping into a score.
keyMessage: Saved weeks are easy to revisit and never become a guilt queue.

## Frame 8 — Quiet by default

- scene: Settings, privacy primer, and one seven-stitch reminder rhythm assemble into three visible trust promises.
- voiceover: "An optional Monday reminder is scheduled on device, and the privacy boundary stays visible."
- duration: 7s
- poster: 8s
- transition_in: push-slide LEFT
- status: animated
- src: compositions/frames/08-quiet-by-default.html
- type: benefit_highlight
- persuasion: User-controlled reassurance
- beat: trust + control
- blueprint: grid-card-assemble
- asset_candidates: assets/07-settings.jpg — Photos, reminder, Plus, and restore settings; assets/10-privacy-primer.jpg — persistent on-device privacy explanation
- focal: assets/07-settings.jpg
- roles: 07-settings = left cutout settings evidence; 10-privacy-primer = right supporting privacy evidence
- sfx: pop

Adapt: keep the short-path card assembly, but cap the evidence at two real surfaces plus three concise trust labels. No floating grid motion after assembly.
Scene 1 (0.0–1.3s): the headline “Quiet by default.” reveals line-by-line above an empty asymmetric grid. A small Plum stitch rail establishes the weekly rhythm; nothing else enters before the narration begins naming controls.
Scene 2 (1.3–3.3s): `07-settings` slides a short distance directly into the left hero slot (`center-outward-expansion`, short-path form). Attached labels “Photos control” and “Monday reminder” reveal top-to-bottom, with the reminder switch area highlighted only as “optional Monday reminder” is spoken.
Scene 3 (3.3–5.2s): `10-privacy-primer` assembles into the right supporting slot; the Sage label “ON-DEVICE ANALYSIS” wipes onto its edge. A thin Plum connector links settings to the primer without suggesting any network transfer.
Scene 4 (5.2–7.0s): three trust statements settle into a compact lower strip—“Optional,” “Scheduled on device,” “Boundary stays visible”—one per soft tick. All surfaces and copy then hold still; no parallax float or camera push.

narrativeRole: Prove that re-engagement and privacy are explicit controls, not hidden growth machinery.
keyMessage: The reminder is optional, local, and subordinate to the privacy boundary.

## Frame 9 — Plus, once

- scene: The real English paywall moves from lifetime benefits to the localized price, restore, Terms, and Privacy controls.
- voiceover: "Two albums are free. Then a one-time lifetime purchase, powered by RevenueCat, unlocks future weeks—no subscription."
- duration: 10s
- poster: 11s
- transition_in: zoom-through
- status: animated
- src: compositions/frames/09-plus-once.html
- type: feature_showcase
- persuasion: Price clarity and subscription risk reversal
- beat: clarity + confidence
- blueprint: device-surface-showcase
- asset_candidates: assets/09-paywall-price.jpg — English lifetime Plus offering, US fixture price, restore, Terms, Privacy, and local-backup limitation
- focal: assets/09-paywall-price.jpg
- roles: 09-paywall-price = cutout hero surface and sole pricing evidence
- sfx: click-soft

Adapt: use a static-tour with controlled crops of the same truthful paywall screenshot. Keep the persistent surface; on-face focus changes reveal the free limit, lifetime product, localized fixture price, restore, and legal links without inventing a purchase completion.
Scene 1 (0.0–2.1s): `09-paywall-price` establishes right-of-center as a large portrait surface. The left claim “2 albums free” reveals as the VO says it; a two-segment Plum progress mark fills (`stat-bars-and-fills`) and stops—never implying recurring billing.
Scene 2 (2.1–4.9s): a static Plum focus bracket moves from the free-limit copy to “Lifetime Plus access” on the real surface; the left claim token-swaps to “ONE-TIME” (`discrete-text-sequence`) exactly on the narration. Camera remains locked.
Scene 3 (4.9–7.5s): the bracket moves once to the real `$19.99` US fixture price and then to Restore; small labels “Localized price” and “Restore purchase” reveal in sequence. A quiet “RevenueCat-powered purchase” utility line appears only as RevenueCat is named, with no success state or transaction animation.
Scene 4 (7.5–10.0s): Terms, Privacy, and the local-backup limitation receive a single bottom-to-top focus sweep; the final line “No subscription.” lands large in Plum and holds for 2.0s. No Subscribe CTA, recurring-price notation, or cloud-backup claim appears.

narrativeRole: Explain the business model precisely without implying that an external sandbox purchase is already complete.
keyMessage: Two albums are free; future weeks unlock through one lifetime RevenueCat purchase, not a subscription.

## Frame 10 — A week worth keeping

- scene: The seven muted stitches assemble first, then resolve into the approved Weekkeep lockup and final line.
- voiceover: "Weekkeep. A week worth keeping."
- duration: 4.5s
- poster: 4s
- transition_in: blur-crossfade
- status: animated
- src: compositions/frames/10-a-week-worth-keeping.html
- type: branding
- persuasion: Memorable verbal and visual closure
- beat: warmth + inevitability
- blueprint: logo-assemble-lockup
- asset_candidates: assets/weekkeep-lockup.svg — approved external exact-seven Weekkeep lockup
- focal: assets/weekkeep-lockup.svg
- roles: weekkeep-lockup = cutout hero and final approved brand truth
- sfx: sparkle, chime

Adapt: use the parts-assembly variant while preserving the exact approved lockup as the final state. Seven DOM stitch accents may introduce the rhythm, but the completed mark is never redrawn or recolored.
Scene 1 (0.0–1.4s): on the Cream field, seven approved muted stitch marks arrive left-to-right in one centered row via short-path stagger (`center-outward-expansion`), each landing on a light tick. No other copy is visible.
Scene 2 (1.4–2.9s): the stitch row contracts toward the center and hands off at identical geometry to the approved `weekkeep-lockup.svg` (`scale-swap-transition`, smooth critically damped settle). The full lockup—including exact seven colors and Plum structure—resolves untouched.
Scene 3 (2.9–4.5s): “A week worth keeping.” wipes in beneath the lockup from left to right; a single Gold underline finishes on “keeping.” The completed lockup and line hold dead static through the last frame; no fade-out is required.

narrativeRole: Leave the judges with one ownable line and the exact-seven visual language.
keyMessage: Weekkeep makes an ordinary family week worth keeping.
