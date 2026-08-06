import Foundation

struct ReviewInteractionReducer: Sendable {
    func reduce(_ state: ReviewPresentationState, action: ReviewAction, photoCount: Int) -> ReviewPresentationState {
        var next = state
        switch action {
        case let .tapPhoto(index):
            guard (0..<photoCount).contains(index) else { return state }
            if state.selectedIndex == index {
                next.destination = .viewer(index: index)
            } else {
                next.selectedIndex = index
                next.destination = nil
            }
        case let .viewPhoto(index):
            guard (0..<photoCount).contains(index) else { return state }
            next.destination = .viewer(index: index)
        case let .replacePhoto(index):
            guard (0..<photoCount).contains(index) else { return state }
            next.destination = .replacement(index: index)
        case .dismissDestination:
            next.destination = nil
        }
        return next
    }
}
