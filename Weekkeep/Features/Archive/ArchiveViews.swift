import SwiftUI

struct ArchiveTabView: View {
    let environment: AppEnvironment
    @State private var model: ArchiveModel
    @State private var path: [String] = []
    @Environment(\.scenePhase) private var scenePhase

    init(environment: AppEnvironment) {
        self.environment = environment
        _model = State(initialValue: ArchiveModel(environment: environment))
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if model.isLoading {
                    ProgressView()
                } else if model.error != nil {
                    ArchiveErrorView { Task { await model.load() } }
                } else if model.albums.isEmpty {
                    ArchiveEmptyView { environment.selectedTab = .week }
                } else {
                    GeometryReader { proxy in
                        let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                                Text("archive.body")
                                    .font(.weekkeepBody)
                                ForEach(model.albums) { album in
                                    NavigationLink(value: album.weekKey) {
                                        WeekRow(album: album, model: model)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("SCR-ARC-01-WeekRow")
                                }
                            }
                            .padding(.horizontal, screenEdge)
                            .padding(.vertical, WeekkeepSpacing.four)
                        }
                    }
                }
            }
            .navigationTitle("archive.title")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { weekKey in
                WeekDetailView(environment: environment, weekKey: weekKey)
            }
        }
        .task {
            await model.load()
            handlePendingDeepLink(environment.pendingDeepLink)
        }
        .onChange(of: environment.pendingDeepLink) { _, link in
            handlePendingDeepLink(link)
        }
        .onChange(of: environment.selectedTab) { _, newValue in
            if newValue == .archive { Task { await model.load() } }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await model.load() }
        }
        .weekkeepScreenBackground()
    }

    private func handlePendingDeepLink(_ link: AppDeepLink?) {
        guard case let .album(weekKey) = link else { return }
        path = [weekKey]
        environment.pendingDeepLink = nil
    }
}

private struct ArchiveErrorView: View {
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("archive.errorTitle", systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
        } description: {
            Text("archive.errorBody")
        } actions: {
            Button("common.retry", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(WeekkeepColors.primaryAction)
        }
    }
}

private struct WeekRow: View {
    let album: WeeklyAlbumSummary
    let model: ArchiveModel
    @State private var coverPhoto: AlbumPhotoSnapshot?

    var body: some View {
        HStack(spacing: WeekkeepSpacing.four) {
            if let coverPhoto {
                PhotoThumbnailView(photo: model.photoReference(from: coverPhoto), photoLibrary: model.environment.photoLibrary)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
                    .accessibilityIdentifier("SCR-ARC-01-Cover")
            } else {
                RoundedRectangle(cornerRadius: WeekkeepRadii.small)
                    .fill(WeekkeepColors.linen)
                    .frame(width: 76, height: 76)
                    .overlay { Image(systemName: "photo") }
            }
            VStack(alignment: .leading, spacing: WeekkeepSpacing.one) {
                Text(WeekkeepLocalization.dateRange(start: album.weekStart, end: album.weekEnd))
                    .font(.weekkeepHeadline)
                Text(WeekkeepLocalization.string("archive.photoCount", album.photoCount))
                    .font(.weekkeepCallout)
                    .foregroundStyle(WeekkeepColors.secondaryText)
                if album.isPartiallyMissing { Text("archive.missing").font(.weekkeepCaption).foregroundStyle(WeekkeepColors.secondaryText) }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(WeekkeepColors.secondaryText)
        }
        .padding(WeekkeepSpacing.three)
        .background(WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
        .overlay { RoundedRectangle(cornerRadius: WeekkeepRadii.medium).stroke(WeekkeepColors.subtleBorder, lineWidth: 1) }
        .accessibilityElement(children: .combine)
        .task(id: album.weekKey) {
            guard let snapshot = try? await model.environment.albumStore.album(for: album.weekKey) else { return }
            coverPhoto = snapshot.photos.first(where: { $0.id == snapshot.coverPhotoID }) ?? snapshot.photos.first
        }
    }
}

private struct ArchiveEmptyView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: WeekkeepSpacing.four) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(WeekkeepColors.success)
            Text("archive.emptyTitle")
                .font(.weekkeepTitle2)
            Text("archive.emptyBody")
                .font(.weekkeepBody)
            WeekkeepPrimaryButton(title: "archive.goToWeek", action: action)
                .padding(.top, WeekkeepSpacing.three)
        }
        .padding(WeekkeepSpacing.six)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WeekDetailView: View {
    let environment: AppEnvironment
    let weekKey: String
    @State private var album: WeeklyAlbumSnapshot?
    @State private var viewerIndex: Int?
    @State private var isSharePreparationPresented = false

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

            ScrollView {
                if let album {
                    VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                        Text(WeekkeepLocalization.dateRange(start: album.weekStart, end: album.weekEnd))
                            .font(.weekkeepTitle2)
                        Text(WeekkeepLocalization.string("detail.savedOnDevice", album.photos.count))
                            .font(.weekkeepCallout)
                            .foregroundStyle(WeekkeepColors.success)
                        if album.isMissingAllPhotos {
                            Text("archive.missingAll")
                                .font(.weekkeepCallout)
                                .foregroundStyle(WeekkeepColors.secondaryText)
                        }
                        WeeklyPhotoGrid(
                            photos: album.photos.map(photoReference),
                            photoLibrary: environment.photoLibrary,
                            selectedIndex: nil,
                            onTap: { viewerIndex = $0 },
                            onView: { viewerIndex = $0 },
                            onReplace: { viewerIndex = $0 }
                        )
                        Text("detail.helper")
                            .font(.weekkeepCallout)
                            .foregroundStyle(WeekkeepColors.secondaryText)
                        Text("privacy.storageBody")
                            .font(.weekkeepCaption)
                            .foregroundStyle(WeekkeepColors.secondaryText)
                    }
                    .padding(.horizontal, screenEdge)
                    .padding(.vertical, WeekkeepSpacing.four)
                } else {
                    VStack(spacing: WeekkeepSpacing.three) {
                        ProgressView()
                        Text("archive.notFound")
                            .font(.weekkeepCallout)
                            .foregroundStyle(WeekkeepColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, minHeight: 220)
                }
            }
        }
        .navigationTitle(WeekkeepLocalization.dateRange(start: album?.weekStart ?? .now, end: album?.weekEnd ?? .now))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSharePreparationPresented = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(album == nil || album?.isMissingAllPhotos == true)
                .accessibilityLabel(Text("share.share"))
                .accessibilityIdentifier("SCR-ARC-02-Share")
            }
        }
        .task {
            guard let loaded = try? await environment.albumStore.album(for: weekKey) else { return }
            let availableIDs = await environment.photoLibrary.assetAvailability(
                for:
                loaded.photos.map(\.assetLocalIdentifier)
            )
            album = loaded.withAvailability(availableIDs)
        }
        .fullScreenCover(isPresented: viewerPresentedBinding) {
            if let album, let index = viewerIndex {
                PhotoViewerView(
                    photos: album.photos.map(photoReference),
                    photoLibrary: environment.photoLibrary,
                    initialIndex: index,
                    onDismiss: { _ in viewerIndex = nil },
                    onReplace: { _ in viewerIndex = nil }
                )
            }
        }
        .sheet(isPresented: $isSharePreparationPresented) {
            if let album {
                WeeklyAlbumShareView(
                    album: album,
                    environment: environment,
                    entryPoint: .archiveDetail
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

    private var viewerPresentedBinding: Binding<Bool> {
        Binding(get: { viewerIndex != nil }, set: { if !$0 { viewerIndex = nil } })
    }
}
