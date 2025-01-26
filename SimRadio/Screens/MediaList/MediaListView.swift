//
//  MediaListView.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 09.12.2024.
//

import Kingfisher
import SwiftUI

struct MediaListView: View {
    let mediaList: MediaList
    @EnvironmentObject var nowPlaying: NowPlayingController
    @Environment(\.nowPlayingExpandProgress) var expandProgress

    @State private var selection: Media.ID?

    var body: some View {
        content
            .contentMargins(.bottom, ViewConst.tabbarHeight + 27, for: .scrollContent)
            .contentMargins(.bottom, ViewConst.tabbarHeight, for: .scrollIndicators)
            .background(Color(.palette.appBackground(expandProgress: expandProgress)))
            .toolbar {
                Button { print("Profile tapped") }
                    label: { ProfileToolbarButton() }
            }
    }
}

private extension MediaListView {
    var content: some View {
        List {
            header
                .padding(.top, 7)
                .padding(.bottom, 26)
                .listRowInsets(.screenInsets)
                .listSectionSeparator(.hidden, edges: .top)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

            list

            footer
                .padding(.top, 17)
                .listRowInsets(.screenInsets)
                .listSectionSeparator(.hidden, edges: .bottom)
                .listRowBackground(Color(.palette.appBackground(expandProgress: expandProgress)))
        }
        .listStyle(.plain)
        .onChange(of: selection) { _, newValue in
            if let newValue {
                if nowPlaying.mediaList.id != mediaList.id {
                    nowPlaying.mediaList = mediaList
                }
                nowPlaying.onPlay(itemId: newValue)
            }
        }
    }

    var header: some View {
        VStack(spacing: 0) {
            let border = UIScreen.hairlineWidth
            KFImage.url(mediaList.artwork)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(Color(.palette.artworkBackground))
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: border / 2)
                        .stroke(Color(.palette.artworkBorder), lineWidth: border)
                )
                .padding(.horizontal, 52)

            Text(mediaList.title)
                .font(.appFont.mediaListHeaderTitle)
                .padding(.top, 18)

            if let subtitle = mediaList.subtitle {
                Text(subtitle)
                    .font(.appFont.mediaListHeaderSubtitle)
                    .foregroundStyle(Color(.palette.textSecondary))
                    .padding(.top, 2)
            }

            buttons
                .padding(.top, 14)
        }
        .listRowBackground(Color(.palette.appBackground(expandProgress: expandProgress)))
    }

    var buttons: some View {
        HStack(spacing: 16) {
            Button {
                print("Play")
            }
            label: {
                buttonLabel("Play", systemImage: "play.fill")
            }

            Button {
                print("Shuffle")
            }
            label: {
                buttonLabel("Shuffle", systemImage: "shuffle")
            }
        }
        .buttonStyle(AppleMusicButtonStyle())
    }

    func buttonLabel(_ title: String, systemImage icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.appFont.button)
        }
    }

    var list: some View {
        ForEach(Array(mediaList.items.enumerated()), id: \.offset) { offset, item in
            let isLastItem = offset == mediaList.items.count - 1
            MediaItemView(
                artwork: item.artwork,
                title: item.title,
                subtitle: item.subtitle
            )
            .contentShape(.rect)
            .listRowInsets(.screenInsets)
            .listRowBackground(
                item.id == selection
                    ? Color(uiColor: .systemGray4)
                    : Color(.palette.appBackground(expandProgress: expandProgress))
            )
            .alignmentGuide(.listRowSeparatorLeading) {
                isLastItem ? $0[.leading] : $0[.leading] + 60
            }
            .swipeActions(edge: .trailing) {
                Button {} label: {
                    Label("Download", systemImage: "arrow.down")
                }
                .tint(.init(.systemBlue))
            }
            .onTapGesture {
                selection = item.id
                Task {
                    try? await Task.sleep(for: .milliseconds(80))
                    selection = nil
                }
            }
        }
    }

    @ViewBuilder
    var footer: some View {
        Text(mediaList.footer)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(.palette.textTertiary))
            .font(.appFont.mediaListItemFooter)
    }
}

struct MediaItemView: View {
    let artwork: URL?
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            let border = UIScreen.hairlineWidth
            KFImage.url(artwork)
                .resizable()
                .frame(width: 48, height: 48)
                .aspectRatio(contentMode: .fill)
                .background(Color(.palette.artworkBackground))
                .clipShape(.rect(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .inset(by: border / 2)
                        .stroke(Color(.palette.artworkBorder), lineWidth: border)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appFont.mediaListItemTitle)
                Text(subtitle ?? "")
                    .font(.appFont.mediaListItemSubtitle)
                    .foregroundStyle(Color(.palette.textTertiary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
        }
        .padding(.top, 4)
        .frame(height: 56, alignment: .top)
    }
}

private extension EdgeInsets {
    static let screenInsets: EdgeInsets = .init(
        top: 0,
        leading: ViewConst.screenPaddings,
        bottom: 0,
        trailing: ViewConst.screenPaddings
    )
}

private extension MediaList {
    var footer: LocalizedStringKey {
        "^[\(items.count) station](inflect: true)"
    }
}

#Preview {
    MediaListView(mediaList: .mockGta5)
}
