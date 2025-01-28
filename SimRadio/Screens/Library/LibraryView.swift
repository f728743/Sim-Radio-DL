import Kingfisher
import SwiftUI

struct LibraryView: View {
    @Environment(\.nowPlayingExpandProgress) var expandProgress
    @Environment(Router.self) var router
    @EnvironmentObject var library: MediaLibrary

    var body: some View {
        List {
            navigationLink(title: "Downloaded", icon: "arrow.down.circle")
                .listRowInsets(.init(top: 0, leading: 23, bottom: 0, trailing: 22))
                .listSectionSeparator(.hidden, edges: .top)
                .listRowBackground(Color(.palette.appBackground(expandProgress: expandProgress)))
                .onTapGesture {
                    router.navigateToDownloaded()
                }
            recentlyAdded
                .listRowInsets(.init(top: 25, leading: 20, bottom: 0, trailing: 20))
                .listSectionSeparator(.hidden, edges: .bottom)
                .listRowBackground(Color(.palette.appBackground(expandProgress: expandProgress)))
        }
        .background(Color(.palette.appBackground(expandProgress: expandProgress)))
        .listStyle(.plain)
        .navigationTitle("Library")
        .toolbar {
            Button { print("Profile tapped") }
                label: { ProfileToolbarButton() }
        }
    }
}

private extension LibraryView {
    var recentlyAdded: some View {
        VStack(spacing: 13) {
            Text("Recently Added")
                .font(.system(size: 22, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {
                ForEach(library.list) { item in
                    RecentlyAddedItem(item: item)
                        .onTapGesture {
                            router.navigateToMediaList(item: item)
                        }
                }
            }
        }
    }

    func navigationLink(title: String, icon: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color(.palette.brand))
            Text(title)
                .font(.system(size: 20))
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.palette.stroke))
        }
        .frame(height: 48)
        .contentShape(.rect)
    }
}

private struct RecentlyAddedItem: View {
    let item: MediaList

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            KFImage.url(item.artwork)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .background(Color(.palette.artworkBackground))
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.palette.artworkBorder), lineWidth: UIScreen.hairlineWidth)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.appFont.mediaListItemSubtitle)
                        .foregroundStyle(Color(.palette.textSecondary))
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var library = MediaLibrary()

    LibraryView()
        .withRouter()
        .environmentObject(library)
        .onAppear {
            library.reload()
        }
}
