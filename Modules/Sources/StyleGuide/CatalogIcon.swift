import SwiftUI

public enum CatalogIcon: String, CaseIterable, Sendable {
    case alert
    case arrowLeft
    case box
    case chevronRight
    case close
    case image
    case refresh
    case returns = "return"
    case search
    case shield
    case star
    case tag
    case truck

    public var view: some View {
        Image("CatalogIcon/\(rawValue)", bundle: .module)
            .resizable()
            .renderingMode(.template)
            .frame(width: Tokens.Size.iconSize, height: Tokens.Size.iconSize)
    }
}
