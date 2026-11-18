import Foundation

struct StandardTrackErrorUseCase: TrackErrorUseCase {
    func execute(error: String, screen: Screen) {
        print("*** TRACK ERROR: \(error) IN \(screen) SCREEN")
    }
}
