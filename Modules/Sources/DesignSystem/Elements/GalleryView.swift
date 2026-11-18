import Localisations
import StyleGuide
import SwiftUI

public struct GalleryView: View {
    private enum Item {
        case image(Image?)
        case remote(URL)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let items: [Item]
    private let title: String

    @State private var currentIndex: Int? = 0

    public init(images: [Image?], title: String) {
        self.items = images.isEmpty ? [.image(nil)] : images.map(Item.image)
        self.title = title
    }

    public init(urls: [URL], title: String) {
        self.items = urls.isEmpty ? [.image(nil)] : urls.map(Item.remote)
        self.title = title
    }

    public var body: some View {
        VStack(spacing: Spacing.s2) {
            track
            if items.count > 1 {
                dots
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.A11y.gallery(title: title))
    }

    private var track: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    makePage(index)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .scrollIndicators(.hidden)
        .aspectRatio(1, contentMode: .fit)
        .background(Color.catalog.surfaceSunken)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
    }

    private var dots: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                let isCurrent = index == (currentIndex ?? 0)

                Button {
                    withAnimation(reduceMotion ? nil : .default) {
                        currentIndex = index
                    }
                } label: {
                    Capsule()
                        .fill(isCurrent ? Color.catalog.ink : Color.catalog.lineStrong)
                        .frame(width: isCurrent ? 16 : 8, height: 8)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.A11y.galleryShow(position: index + 1))
                .accessibilityAddTraits(isCurrent ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func makePage(_ index: Int) -> some View {
        switch items[index] {
        case .image(let image):
            makeImageWell(image, index: index)

        case .remote(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.catalog.surfaceSunken
                        ProgressView()
                    }
                    .accessibilityLabel(makeImageTitle(index))

                case .success(let image):
                    makeImageWell(image, index: index)

                case .failure:
                    makeImageWell(nil, index: index)

                @unknown default:
                    makeImageWell(nil, index: index)
                }
            }
        }
    }

    private func makeImageWell(_ image: Image?, index: Int) -> some View {
        ImageWellView(image: image, inset: Spacing.s4, placeholderSize: 32, title: makeImageTitle(index))
    }

    private func makeImageTitle(_ index: Int) -> String {
        guard items.count > 1 else { return title }
        return L10n.A11y.galleryImage(title: title, position: index + 1, total: items.count)
    }
}

#if DEBUG

#Preview {
    ScrollView {
        VStack(spacing: Spacing.s6) {
            GalleryView(
                images: [
                    Image(systemName: "shippingbox.fill"),
                    nil,
                    Image(systemName: "tag.fill")
                ],
                title: "Essence Mascara Lash Princess"
            )
            GalleryView(images: [Image(systemName: "shippingbox.fill")], title: "One image")
            GalleryView(images: [], title: "No images")
        }
        .padding(Spacing.s4)
    }
    .background(Color.catalog.surface)
}

#endif
