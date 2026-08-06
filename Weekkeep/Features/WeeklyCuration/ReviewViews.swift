import SwiftUI

extension ReviewDestination: Identifiable {
  var id: String {
    switch self {
    case .viewer(let index): "viewer-\(index)"
    case .replacement(let index): "replacement-\(index)"
    }
  }
}

/// Semantic spacing contract for the photo-first Weekly Review hierarchy.
///
/// These values deliberately remain the same for production and deterministic
/// screenshot fixtures. App Store captures frame the scrollable surface at
/// different scroll positions instead of changing the product layout.
enum WeeklyReviewSpacing {
  static let screenEdge = WeekkeepScreenLayout.defaultHorizontalPadding
  static let smallScreenEdge = WeekkeepScreenLayout.smallScreenHorizontalPadding
  static func screenEdge(for width: CGFloat) -> CGFloat {
    WeekkeepScreenLayout.horizontalPadding(for: width)
  }
  static let screenTop = WeekkeepSpacing.four
  static let headerCluster = WeekkeepSpacing.two
  static let headerToEditorial = WeekkeepSpacing.eight
  static let titleBodyEditorial = WeekkeepSpacing.three
  static let partialNotice = WeekkeepSpacing.six
  static let editorialToMedia = WeekkeepSpacing.eight
  static let mediaGrid = WeekkeepSpacing.two
  static let helperReplace = WeekkeepSpacing.four
  static let privacy = WeekkeepSpacing.four
  static let primaryAction = WeekkeepSpacing.six
  static let screenBottom = WeekkeepSpacing.six
  // Extra real content runway lets the review settle with the editorial
  // section wholly below the system boundary or wholly behind the Cream
  // occluder before the lower actions are framed.
  static let scrollRunway = WeekkeepSpacing.sixteen + WeekkeepSpacing.two
}

struct WeeklyReviewView: View {
  static let partialSuccessAccessibilityIdentifier = "SCR-WK-03-PartialSuccess"

  let model: WeeklyFlowModel
  @Environment(\.weekkeepWindowSafeAreaTop) private var windowSafeAreaTop

  var body: some View {
    GeometryReader { proxy in
      let screenEdge = WeeklyReviewSpacing.screenEdge(for: proxy.size.width)
      // RootView resolves the runtime-first system boundary once. Keep the
      // local proxy inset as an additional runtime measurement, but do not
      // reintroduce a device-independent global fallback here.
      let occlusionHeight = max(windowSafeAreaTop, proxy.safeAreaInsets.top)

      ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            WeeklyReviewHeaderCluster(
              dateRange: dateRange,
              filledCount: model.draft?.selected.count ?? 0,
              selectedIndex: model.reviewPresentation.selectedIndex,
              onBack: model.cancelReview
            )
            WeeklyReviewEditorialGroup(
              title: title,
              copy: model.draft.map { WeekkeepLocalization.string("review.body", $0.selected.count) }
            )
            .padding(.top, WeeklyReviewSpacing.headerToEditorial)
            if let draft = model.draft {
              if model.reviewState.isPartialSuccess {
                Text("curation.partial")
                  .font(.weekkeepCallout)
                  .foregroundStyle(WeekkeepColors.secondaryText)
                  .padding(WeekkeepSpacing.four)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(
                    WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.medium)
                  )
                  .overlay {
                    RoundedRectangle(cornerRadius: WeekkeepRadii.medium)
                      .stroke(WeekkeepColors.subtleBorder, lineWidth: 1)
                  }
                  .accessibilityElement(children: .ignore)
                  .accessibilityLabel(Text("curation.partial"))
                  .accessibilityIdentifier(Self.partialSuccessAccessibilityIdentifier)
                  .padding(.top, WeeklyReviewSpacing.partialNotice)
              }
              WeeklyPhotoGrid(
                photos: draft.selected,
                photoLibrary: model.environment.photoLibrary,
                selectedIndex: model.reviewPresentation.selectedIndex,
                onTap: model.tapPhoto(at:),
                onView: model.viewPhoto(at:),
                onReplace: model.replacePhoto(at:),
                spacing: WeeklyReviewSpacing.mediaGrid
              )
              .padding(.top, WeeklyReviewSpacing.editorialToMedia)

              WeeklyReviewPostGridActions(
                isReplacementAvailable: model.reviewPresentation.selectedIndex.map {
                  draft.selected.indices.contains($0)
                } ?? false,
                onReplace: {
                  if let selectedIndex = model.reviewPresentation.selectedIndex {
                    model.replacePhoto(at: selectedIndex)
                  }
                }
              )
              .padding(.top, WeeklyReviewSpacing.helperReplace)

              PrivacyBadge(title: "week.privacy")
                .padding(.top, WeeklyReviewSpacing.privacy)

              WeekkeepPrimaryButton(
                renderedTitle: WeekkeepLocalization.string("review.keep", draft.selected.count),
                action: model.saveDraft,
                isLoading: model.isSaving
              )
              .disabled(model.isSaving)
              .padding(.top, WeeklyReviewSpacing.primaryAction)
              .accessibilityIdentifier("SCR-WK-03-Save")
            }
          }
          .padding(.horizontal, screenEdge)
          .padding(.top, WeeklyReviewSpacing.screenTop)
          .padding(.bottom, WeeklyReviewSpacing.screenBottom + WeeklyReviewSpacing.scrollRunway)
      }
      .scrollIndicators(.hidden)
      // The review route is hosted by the tab shell, whose scroll surface can
      // extend behind the system status region. Keep the header free to
      // scroll, but invisibly mask unsafe-area content with the same Cream
      // surface so text never remains legible beneath system indicators.
      .overlay(alignment: .top) {
        WeekkeepColors.primaryBackground
          .frame(maxWidth: .infinity)
          .frame(height: occlusionHeight)
          .offset(y: -occlusionHeight)
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
    }
    .fullScreenCover(item: viewerBinding) { destination in
      if case .viewer(let index) = destination, let draft = model.draft {
        PhotoViewerView(
          photos: draft.selected,
          photoLibrary: model.environment.photoLibrary,
          initialIndex: index,
          onDismiss: model.dismissViewer(at:),
          onReplace: { replacementIndex in
            model.reviewPresentation.destination = nil
            DispatchQueue.main.async { model.replacePhoto(at: replacementIndex) }
          }
        )
      }
    }
    .sheet(item: replacementBinding) { destination in
      if case .replacement(let index) = destination,
        let draft = model.draft,
        draft.selected.indices.contains(index)
      {
        ReplacePhotoSheet(
          current: draft.selected[index],
          sameDayCandidates: model.sameDayReplacementCandidates,
          otherDayCandidates: model.otherDayReplacementCandidates,
          showOtherDays: model.replacementShowsOtherDays,
          photoLibrary: model.environment.photoLibrary,
          timeZoneIdentifier: model.environment.weekCalculator.timeZoneIdentifier,
          onSelect: { candidate in model.chooseReplacement(candidate, at: index) },
          onSeeOtherDays: model.showOtherDayReplacementCandidates,
          onCancel: { model.reviewPresentation.destination = nil }
        )
        .presentationDetents([.medium, .large])
      }
    }
    .onAppear {
      model.setReviewVisible(true)
    }
    .onDisappear { model.setReviewVisible(false) }
    .weekkeepScreenBackground()
  }

  private var dateRange: String {
    guard let week = model.draft?.week else { return "" }
    return WeekkeepLocalization.dateRange(
      start: week.start,
      end: week.end,
      timeZone: TimeZone(identifier: model.environment.weekCalculator.timeZoneIdentifier) ?? .gmt
    )
  }

  private var title: String {
    guard let draft = model.draft else { return "" }
    if draft.kind == .welcome {
      return WeekkeepLocalization.string("review.welcomeTitle")
    }
    return WeekkeepLocalization.string("review.regularTitle")
  }

  private var viewerBinding: Binding<ReviewDestination?> {
    Binding(
      get: {
        guard let destination = model.reviewPresentation.destination else { return nil }
        if case .viewer = destination { return destination }
        return nil
      },
      set: { newValue in
        if newValue == nil { model.reviewPresentation.destination = nil }
      }
    )
  }

  private var replacementBinding: Binding<ReviewDestination?> {
    Binding(
      get: {
        guard let destination = model.reviewPresentation.destination else { return nil }
        if case .replacement = destination { return destination }
        return nil
      },
      set: { newValue in
        if newValue == nil { model.reviewPresentation.destination = nil }
      }
    )
  }
}

private struct WeeklyReviewEditorialGroup: View {
  let title: String
  let copy: String?

  var body: some View {
    VStack(alignment: .leading, spacing: WeeklyReviewSpacing.titleBodyEditorial) {
      Text(title)
        .font(.weekkeepTitle)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("SCR-WK-03-Title")
      if let copy {
        Text(copy)
          .font(.weekkeepBody)
          .accessibilityIdentifier("SCR-WK-03-Body")
      }
    }
  }
}

private struct WeeklyReviewPostGridActions: View {
  let isReplacementAvailable: Bool
  let onReplace: () -> Void

  @ViewBuilder
  var body: some View {
    if isReplacementAvailable {
      WeekkeepSecondaryButton(title: "review.replace", action: onReplace)
        .accessibilityIdentifier("SCR-WK-03-ReplaceSelected")
        .transition(.opacity)
    } else {
      Text("review.helper")
        .font(.weekkeepCallout)
        .foregroundStyle(WeekkeepColors.secondaryText)
    }
  }
}

private struct WeeklyReviewHeaderCluster: View {
  let dateRange: String
  let filledCount: Int
  let selectedIndex: Int?
  let onBack: () -> Void

  var body: some View {
    HStack(alignment: .center, spacing: WeeklyReviewSpacing.headerCluster) {
      Button(action: onBack) {
        Image(systemName: "chevron.left")
          .font(.system(size: 18, weight: .semibold))
          .frame(width: 44, height: 44)
      }
      .accessibilityLabel(Text("common.back"))

      VStack(alignment: .leading, spacing: WeekkeepSpacing.one) {
        Text("tab.week")
          .font(.weekkeepNavigation)
          .foregroundStyle(WeekkeepColors.primaryText)
        Text(dateRange)
          .font(.weekkeepCaption)
          .foregroundStyle(WeekkeepColors.secondaryText)
          .lineLimit(1)
      }

      Spacer(minLength: WeeklyReviewSpacing.headerCluster)

      SevenStitchRail(
        filledCount: filledCount,
        tone: .coral,
        selectedIndex: selectedIndex
      )
      .frame(width: 88, height: 24)
    }
    .foregroundStyle(WeekkeepColors.primaryText)
    .accessibilityIdentifier("SCR-WK-03-Header")
  }
}

struct PhotoViewerView: View {
  let photos: [PhotoReference]
  let photoLibrary: any PhotoLibraryClient
  let onDismiss: (Int) -> Void
  let onReplace: (Int) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var currentIndex: Int

  init(
    photos: [PhotoReference],
    photoLibrary: any PhotoLibraryClient,
    initialIndex: Int,
    onDismiss: @escaping (Int) -> Void,
    onReplace: @escaping (Int) -> Void
  ) {
    self.photos = photos
    self.photoLibrary = photoLibrary
    self.onDismiss = onDismiss
    self.onReplace = onReplace
    _currentIndex = State(initialValue: min(max(initialIndex, 0), max(photos.count - 1, 0)))
  }

  var body: some View {
    VStack(spacing: WeekkeepSpacing.four) {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel(Text("common.close"))
        Spacer()
        Text(WeekkeepLocalization.string("viewer.position", currentIndex + 1, photos.count))
          .font(.weekkeepCallout)
          .accessibilityIdentifier("SCR-WK-04-Position")
        Spacer()
        Color.clear.frame(width: 44, height: 44)
      }
      .padding(.horizontal, WeekkeepSpacing.four)
      .foregroundStyle(WeekkeepColors.primaryText)

      TabView(selection: $currentIndex) {
        ForEach(photos.indices, id: \.self) { index in
          PhotoThumbnailView(photo: photos[index], photoLibrary: photoLibrary, contentMode: .fit)
            .tag(index)
            .padding(.horizontal, WeekkeepSpacing.two)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))

      Text("viewer.swipe")
        .font(.weekkeepCallout)
        .foregroundStyle(WeekkeepColors.secondaryText)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: WeekkeepSpacing.two) {
          ForEach(photos.indices, id: \.self) { index in
            PhotoThumbnailView(photo: photos[index], photoLibrary: photoLibrary)
              .frame(width: 50, height: 64)
              .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
              .overlay {
                RoundedRectangle(cornerRadius: WeekkeepRadii.small).stroke(
                  index == currentIndex ? WeekkeepColors.memoryAccent : WeekkeepColors.subtleBorder,
                  lineWidth: index == currentIndex ? 2 : 1)
              }
              .onTapGesture { currentIndex = index }
          }
        }
        .padding(.horizontal, WeekkeepSpacing.four)
      }
      WeekkeepSecondaryButton(title: "review.replace") {
        onReplace(currentIndex)
      }
      .padding(.horizontal, WeekkeepSpacing.four)
      .padding(.bottom, WeekkeepSpacing.four)
    }
    .onDisappear { onDismiss(currentIndex) }
    .weekkeepScreenBackground()
  }
}

struct ReplacePhotoSheet: View {
  let current: PhotoReference
  let sameDayCandidates: [PhotoReference]
  let otherDayCandidates: [PhotoReference]
  let showOtherDays: Bool
  let photoLibrary: any PhotoLibraryClient
  let timeZoneIdentifier: String
  let onSelect: (PhotoReference) -> Void
  let onSeeOtherDays: () -> Void
  let onCancel: () -> Void

  var body: some View {
    let availability = ReplacementCandidatePresentation(
      sameDayCount: sameDayCandidates.count,
      otherDayCount: otherDayCandidates.count
    )

    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.four) {
          Text("replace.current")
            .font(.weekkeepHeadline)
          PhotoThumbnailView(photo: current, photoLibrary: photoLibrary)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
          Text("replace.sameDay")
            .font(.weekkeepHeadline)
            .padding(.top, WeekkeepSpacing.three)
            .accessibilityIdentifier("SHEET-REP-01-SameDay")
          if availability.showsCloseOnly {
            Text("replace.none")
              .font(.weekkeepBody)
              .foregroundStyle(WeekkeepColors.secondaryText)
              .accessibilityIdentifier("SHEET-REP-01-None")
          } else if sameDayCandidates.isEmpty {
            Text("replace.sameDayNone")
              .font(.weekkeepBody)
              .foregroundStyle(WeekkeepColors.secondaryText)
            if availability.showsOtherDaysAction {
              WeekkeepSecondaryButton(title: "replace.seeOtherDays", action: onSeeOtherDays)
                .accessibilityIdentifier("SHEET-REP-01-SeeOtherDays")
            }
          } else {
            ReplacementCandidateGrid(
              candidates: sameDayCandidates,
              photoLibrary: photoLibrary,
              timeZoneIdentifier: timeZoneIdentifier,
              onSelect: onSelect
            )
            if !showOtherDays && availability.showsOtherDaysAction {
              Button("replace.seeOtherDays", action: onSeeOtherDays)
                .font(.weekkeepCallout)
                .foregroundStyle(WeekkeepColors.secondaryAction)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("SHEET-REP-01-SeeOtherDays")
            }
          }
          if showOtherDays && !otherDayCandidates.isEmpty {
            Text("replace.otherDays")
              .font(.weekkeepHeadline)
              .padding(.top, WeekkeepSpacing.three)
              .accessibilityIdentifier("SHEET-REP-01-OtherDays")
            ForEach(otherDayGroups, id: \.key) { group in
              Text(WeekkeepLocalization.dayLabel(group.date, timeZone: displayTimeZone))
                .font(.weekkeepCallout)
                .foregroundStyle(WeekkeepColors.secondaryText)
              ReplacementCandidateGrid(
                candidates: group.candidates,
                photoLibrary: photoLibrary,
                timeZoneIdentifier: timeZoneIdentifier,
                onSelect: onSelect
              )
            }
          }
        }
        .padding(WeekkeepSpacing.four)
      }
      .navigationTitle("replace.title")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(availability.showsCloseOnly ? "common.close" : "common.cancel", action: onCancel)
            .accessibilityIdentifier(
              availability.showsCloseOnly ? "SHEET-REP-01-Close" : "SHEET-REP-01-Cancel"
            )
        }
      }
    }
    .weekkeepScreenBackground()
  }

  private struct CandidateGroup {
    let key: String
    let date: Date
    let candidates: [PhotoReference]
  }

  private var displayTimeZone: TimeZone {
    TimeZone(identifier: timeZoneIdentifier) ?? .gmt
  }

  private var otherDayGroups: [CandidateGroup] {
    Dictionary(grouping: otherDayCandidates) {
      $0.calendarDayKey(timeZoneIdentifier: timeZoneIdentifier)
    }
    .compactMap { key, candidates in
      guard let date = candidates.first?.capturedAt else { return nil }
      return CandidateGroup(key: key, date: date, candidates: candidates)
    }
    .sorted { $0.date < $1.date }
  }
}

private struct ReplacementCandidateGrid: View {
  let candidates: [PhotoReference]
  let photoLibrary: any PhotoLibraryClient
  let timeZoneIdentifier: String
  let onSelect: (PhotoReference) -> Void

  var body: some View {
    LazyVGrid(
      columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WeekkeepSpacing.three
    ) {
      ForEach(Array(candidates.enumerated()), id: \.element.id) { index, candidate in
        Button {
          onSelect(candidate)
        } label: {
          VStack(alignment: .leading, spacing: WeekkeepSpacing.one) {
            PhotoThumbnailView(photo: candidate, photoLibrary: photoLibrary)
              .aspectRatio(1, contentMode: .fit)
              .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
            Text(
              WeeklyReviewDateFormatting.candidateLabel(
                candidate.capturedAt,
                timeZoneIdentifier: timeZoneIdentifier
              )
            )
              .font(.weekkeepCaption)
              .foregroundStyle(WeekkeepColors.secondaryText)
          }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
          Text(
            WeeklyReviewDateFormatting.candidateLabel(
              candidate.capturedAt,
              timeZoneIdentifier: timeZoneIdentifier
            )
          )
        )
        .accessibilityIdentifier("SHEET-REP-01-Candidate-\(index)")
      }
    }
    .accessibilityIdentifier("SHEET-REP-01-Content")
  }
}

struct SaveConfirmationView: View {
  let model: WeeklyFlowModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var visibleCount = 0
  @State private var isSharePreparationPresented = false

  var body: some View {
    GeometryReader { proxy in
      let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

      ScrollView {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
          HStack {
            Spacer()
            SevenStitchRail(filledCount: model.savedAlbum?.photos.count ?? 0, tone: .sage)
            Spacer()
          }
          .padding(.top, WeekkeepSpacing.six)
          Text("save.title")
            .font(.weekkeepTitle)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("SCR-WK-05-Title")
          if let album = model.savedAlbum {
            Text(WeekkeepLocalization.string("save.metadata", album.photos.count))
              .font(.weekkeepCallout)
              .foregroundStyle(WeekkeepColors.success)
              .frame(maxWidth: .infinity, alignment: .center)
            let photos = Array(album.photos.prefix(min(visibleCount, album.photos.count))).map(
              photoReference)
            WeeklyPhotoGrid(
              photos: photos,
              photoLibrary: model.environment.photoLibrary,
              selectedIndex: nil,
              onTap: { _ in },
              onView: { _ in },
              onReplace: { _ in }
            )
            Text("save.body")
              .font(.weekkeepBody)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)
          }
          Spacer()
          WeekkeepPrimaryButton(title: "save.share") {
            isSharePreparationPresented = true
          }
          .accessibilityIdentifier("SCR-WK-05-Share")
          WeekkeepSecondaryButton(title: "save.view") {
            model.finishSave(openArchive: true)
          }
          .accessibilityIdentifier("SCR-WK-05-View")
          Button("save.done") {
            model.finishSave()
          }
          .font(.weekkeepCallout)
          .foregroundStyle(WeekkeepColors.secondaryAction)
          .frame(maxWidth: .infinity, minHeight: 44)
          .accessibilityIdentifier("SCR-WK-05-Done")
        }
        .padding(.horizontal, screenEdge)
        .padding(.bottom, WeekkeepSpacing.four)
      }
      .scrollIndicators(.hidden)
    }
    .task(id: model.savedAlbum?.id) {
      let total = model.savedAlbum?.photos.count ?? 0
      guard total > 0 else {
        visibleCount = 0
        return
      }
      if reduceMotion {
        visibleCount = total
      } else {
        visibleCount = 0
        for count in 1...total {
          try? await Task.sleep(for: .milliseconds(70))
          guard !Task.isCancelled else { return }
          visibleCount = count
        }
      }
    }
    .sheet(isPresented: $isSharePreparationPresented) {
      if let album = model.savedAlbum {
        WeeklyAlbumShareView(
          album: album,
          environment: model.environment,
          entryPoint: .saveConfirmation
        )
        .presentationDetents([.large])
      }
    }
    .weekkeepScreenBackground()
  }

  private func photoReference(_ photo: AlbumPhotoSnapshot) -> PhotoReference {
    PhotoReference(
      id: photo.assetLocalIdentifier,
      capturedAt: photo.capturedAt ?? Date.distantPast,
      pixelWidth: 1_200,
      pixelHeight: 1_600,
      score: photo.scoreSnapshot ?? 0.5,
      source: photo.source
    )
  }
}
