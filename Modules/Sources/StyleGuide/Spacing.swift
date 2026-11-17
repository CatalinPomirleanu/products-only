import SwiftUI

/// 4pt base. `s4` is the side gutter of every screen.
public enum Spacing {
    /// Between a star row and its number; between stacked text lines in a card.
    public static let s1: CGFloat = 4
    /// Inside badges and tags; between tags; between an icon and its label.
    public static let s2: CGFloat = 8
    /// Card padding, the gap between a thumbnail and its text, the gap between cards in the list.
    public static let s3: CGFloat = 12
    /// Screen side gutter; padding of blocks on the details page; spec row height padding.
    public static let s4: CGFloat = 16
    /// Between sections on the details page.
    public static let s6: CGFloat = 24
    /// Around an empty state; bottom padding of a screen.
    public static let s8: CGFloat = 32
}
