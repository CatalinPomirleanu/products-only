import Core
import SwiftUI

extension View {
    public var ccp: Core.Namespace<some View> { Namespace(base: self) }
}
