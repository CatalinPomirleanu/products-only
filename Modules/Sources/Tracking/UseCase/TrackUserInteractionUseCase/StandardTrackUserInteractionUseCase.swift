import Foundation

struct StandardTrackUserInteractionUseCase: TrackUserInteractionUseCase {
    func execute(interaction: UserInteraction, screen: Screen) {
        switch interaction {
        case .gesture(let trackingData):
            print("*** TRACK USER GESTURE: \(trackingData) IN \(screen) SCREEN")
        }
    }
}
