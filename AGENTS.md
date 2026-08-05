# Weekkeep Agent Instructions

These instructions apply to every agent working inside this repository.

## Current phase

The project is in **Implementation**. The human product owner approved the 0.5 documentation baseline on 2026-08-05; all derived implementation gates are Ready. Build production code and tests against `docs/00-INDEX.md` and keep traceability evidence current. Product-scope changes still require a Decision Registry/PRD update before code diverges.

## Required reading order

Before changing product behavior, read:

1. `docs/00-INDEX.md`, including the canonical Decision Registry
2. `docs/01-PRD.md`
3. the relevant use cases in `docs/02-USE-CASES.md`
4. the relevant screens in `docs/03-IA.md`
5. `docs/04-TRD.md`
6. the relevant rules in `docs/05-DESIGN-GUIDE.md`
7. `design/README.md` for the current visual baseline and archive boundaries
8. `docs/06-TRACEABILITY.md`

Use `docs/07-DELIVERY-PLAN.md` for sequence and release gates. Follow the responsibility boundaries in `docs/00-INDEX.md`; no document may silently expand PRD scope or redefine a decision value.

## Non-negotiable product contracts

- Weekkeep helps a parent keep one week in at most seven photos.
- Initial selection is at most seven; alternatives are at most seven.
- A regular week is Monday 00:00 through Sunday 23:59 in local time. It becomes eligible the following Monday and remains the current target for seven days.
- The default reminder is Monday at 20:30 local time. It must invite the parent back without claiming that foreground curation already finished.
- The recurring task is review-first: accept the proposed draft as-is or replace only unwanted photos. Target active user effort is at most 60 seconds, excluding foreground analysis wait.
- If a week is missed, offer only the latest completed week. Never create a backlog, streak loss, or guilt mechanic.
- Never backfill an under-seven result with photos outside the requested date range.
- Do not claim to identify a child or family member.
- Photo pixels, thumbnails, local identifiers, filenames, locations, and capture timestamps must not enter analytics or vendor payloads.
- V1 is iPhone/iOS 18+, local-only, with no account, backend, or CloudKit. Weekkeep provides no app-managed backup or guaranteed cross-device restore, so saved selections may be lost after app deletion or device replacement; purchase restore restores Plus only.
- Welcome 포함 최초 2개의 저장 기록은 무료다. 사진 1장 이상인 세 번째 미저장 target의 생성부터 Plus를 요구하며, 기존 저장 기록 열람은 막지 않는다.
- Plus는 비소모성 평생 이용권 1개다. App Store Connect의 US 기준 가격은 $19.99이고 다른 storefront는 Apple 자동 등가 가격을 사용한다. production UI는 RevenueCat/App Store 현지화 가격만 표시하며 KR 약 ₩29,000을 하드코딩하지 않는다.
- Previously saved albums remain readable without Plus.
- RevenueCat is the purchase source of truth; a local boolean is not.
- Analysis runs in the foreground and must be cancellable. A notification is a reminder, not a claim that background analysis completed.
- The current V1 visual baseline is App Screens V2: Light only, LINE Seed Sans KR, solid Plum CTA, hero+2+4 for seven photos, adaptive layouts for 1–6, and a code-rendered SevenStitchRail with exactly seven slots.
- In Weekly Review, the first photo tap selects and reveals the replacement action; a second tap on the selected photo opens the viewer. VoiceOver must expose direct view and replace actions without requiring this sequence.

## Change control

- Change a decision value or status only in the `docs/00-INDEX.md` Decision Registry, then update its dependent contracts.
- Change product scope in PRD first.
- Change behavior in Use Cases and IA together.
- Record implementation consequences in TRD/ADR; ADRs reference Decision IDs and do not keep an independent approval status.
- Update Design Guide for visual, interaction, accessibility, or copy changes.
- Update `design/README.md` whenever the current visual baseline or design authority map changes; never promote a legacy/exploration image implicitly.
- Update Traceability whenever an FR, UC, SCR, CMP, ADR, EVT, or TST changes.
- Preserve IDs. Mark removed requirements `Deprecated`; do not renumber them.
- Approved launch configuration과 시장 검증 상태를 구분한다. 무료 한도·기준 가격은 `D-008`·`D-023`의 구현값을 따르되 수용 가능성은 `H-003`·`H-004`가 검증될 때까지 가설로 유지한다.

## Engineering rules after approval

- Swift 6 strict concurrency; UI state changes on MainActor.
- Keep views small and feature state local. Do not create a global giant ViewModel.
- Keep Photos, Vision, RevenueCat, PostHog, and notification APIs behind adapters.
- PostHog is anonymous explicit-capture only. Do not identify users, enable person profiles, swizzling, lifecycle/screen/element autocapture, rage clicks, session replay, surveys, feature flags, or tracing.
- `project.yml` is the Xcode project SSOT under XcodeGen 2.46.0. Do not commit or hand-edit the generated `.xcodeproj`.
- Do not move `PHAsset` across isolation boundaries; pass local value types.
- Use semantic design tokens; no raw colors or fixed typography in feature views.
- Make core curation deterministic and testable with fixture data.
- Store a maximum of one `WeeklyAlbum` per `weekKey` using atomic upsert.
- Do not log photo identifiers even with private log interpolation.
- Treat limited Photos access as supported behavior, not an error.

## Verification

A feature is not done until its linked test in `docs/06-TRACEABILITY.md` passes and evidence is recorded. At minimum verify:

- normal, empty, limited, denied, partial, error, and cancellation states
- Korean and English
- Light appearance, VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, and absence of unintended dark surfaces
- real-device Photos/iCloud behavior where relevant
- network payloads contain no photo-related data
- purchase success, cancel, pending, failure, and restore where relevant

## Legacy Peeka repository

`/Users/solkim/Dev/baby_album` is reference material only. Do not edit it from Weekkeep work. Do not copy its project, persistence model, CloudKit, widgets, cleanup feature, StoreKit layer, or ViewModel structure. Port a proven algorithm only after writing a Weekkeep contract and fixture test for it.

## Communication

- Collaborate with the product owner primarily in Korean.
- Use English for Swift identifiers and user-facing English localization.
- Report outcomes and evidence, not commit count or lines of code.
- Build-in-public content aimed at parents must lead with their problem and the product outcome.
