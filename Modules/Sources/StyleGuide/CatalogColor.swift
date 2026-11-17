import SwiftUI

extension Color {
    /// Usage: `.foregroundStyle(Color.catalog.ink)`. Each colour has a light and a dark value in the asset catalog,
    /// which ships in this module's bundle.
    public enum catalog {
        /// Screen background behind the product list and the details page.
        public static let surface = Color("CatalogColor/surface", bundle: .module)
        /// Product cards, the search field, the top bar and any grouped block on the details page.
        public static let surfaceRaised = Color("CatalogColor/surfaceRaised", bundle: .module)
        /// Image wells behind thumbnails and gallery images, skeleton blocks while the list loads, the pressed state of a card.
        public static let surfaceSunken = Color("CatalogColor/surfaceSunken", bundle: .module)
        /// Decorative hairlines: card borders, row separators in spec lists and reviews. Carries no meaning, so it is not held to 3:1.
        public static let line = Color("CatalogColor/line", bundle: .module)
        /// Borders that mark a control (search field, secondary button, tag) and the unfilled part of rating stars. At least 3:1 on surface, surface-raised and surface-sunken in both themes.
        public static let lineStrong = Color("CatalogColor/lineStrong", bundle: .module)
        /// Primary text and icons on surface, surface-raised and surface-sunken: titles, prices, body copy, filled rating stars.
        public static let ink = Color("CatalogColor/ink", bundle: .module)
        /// Secondary text on surface, surface-raised and surface-sunken: brand, spec labels, dates, the struck-through original price, placeholder text.
        public static let inkMuted = Color("CatalogColor/inkMuted", bundle: .module)
        /// Fill of the primary button. An alias of ink: the system has no brand hue for actions, so the loud colour stays free for discounts.
        public static let action = Color("CatalogColor/action", bundle: .module)
        /// Label and icon on an action fill.
        public static let onAction = Color("CatalogColor/onAction", bundle: .module)
        /// Fill of the discount sticker, and nothing else. Never a text colour: it fails contrast on the light surfaces.
        public static let sticker = Color("CatalogColor/sticker", bundle: .module)
        /// Text on a sticker fill (the discount percentage).
        public static let onSticker = Color("CatalogColor/onSticker", bundle: .module)
        /// availabilityStatus "In Stock". As text on positive-soft, surface or surface-raised. A teal, not a green, so it stays apart from danger for red-green colour blindness.
        public static let positive = Color("CatalogColor/positive", bundle: .module)
        /// Badge background behind positive text.
        public static let positiveSoft = Color("CatalogColor/positiveSoft", bundle: .module)
        /// availabilityStatus "Low Stock". As text on caution-soft, surface or surface-raised.
        public static let caution = Color("CatalogColor/caution", bundle: .module)
        /// Badge background behind caution text.
        public static let cautionSoft = Color("CatalogColor/cautionSoft", bundle: .module)
        /// availabilityStatus "Out of Stock" and the failed-to-load state. As text on danger-soft, surface or surface-raised.
        public static let danger = Color("CatalogColor/danger", bundle: .module)
        /// Badge and icon-disc background behind danger text.
        public static let dangerSoft = Color("CatalogColor/dangerSoft", bundle: .module)
    }
}
