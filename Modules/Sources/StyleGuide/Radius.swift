import SwiftUI

extension Tokens {
    /// Corners grow with the object; `full` is for the sticker, tags, icon buttons and dots.
    public enum Radius {
        /// Status badges.
        public static let sm: CGFloat = 6
        /// Buttons, the search field, list thumbnails.
        public static let md: CGFloat = 10
        /// Product cards, the gallery image well, grouped blocks on the details page.
        public static let lg: CGFloat = 16
        /// The discount sticker, tags, icon buttons, gallery dots.
        public static let full: CGFloat = 9999
    }
}
