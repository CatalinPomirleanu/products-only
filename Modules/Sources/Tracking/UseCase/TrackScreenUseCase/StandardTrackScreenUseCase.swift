import Foundation

struct StandardTrackScreenUseCase: TrackScreenUseCase {
    func execute(screen: Screen) {
        print("*** TRACK SCREEN VIEW: \(screen)")
    }
}
