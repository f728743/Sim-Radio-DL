//
//  OverlaidRootView.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 17.11.2024.
//

import SwiftUI

struct OverlaidRootView: View {
    @State private var nowPlayingExpandProgress: CGFloat = .zero
    @State private var showOverlayingNowPlayng: Bool = false
    @State private var expandedNowPlaying: Bool = false
    @State private var showNowPlayingReplacement: Bool = false

    @EnvironmentObject var playerController: NowPlayingController

    var body: some View {
        ZStack(alignment: .bottom) {
            RootView()
            CompactNowPlayingReplacement(expanded: .constant(false))
                .opacity(showNowPlayingReplacement ? 1 : 0)
        }
        .universalOverlay(animation: .none, show: $showOverlayingNowPlayng) {
            ExpandableNowPlaying(
                show: $showOverlayingNowPlayng,
                expanded: $expandedNowPlaying
            )
            .environmentObject(playerController)
            .onPreferenceChange(NowPlayingExpandProgressPreferenceKey.self) { [$nowPlayingExpandProgress] value in
                $nowPlayingExpandProgress.wrappedValue = value
            }
        }
        .onAppear {
            showOverlayingNowPlayng = true
        }
        .environment(\.nowPlayingExpandProgress, nowPlayingExpandProgress)
    }

    func showNowPlayng(replacement: Bool) {
        guard !expandedNowPlaying else { return }
        showOverlayingNowPlayng = !replacement
        showNowPlayingReplacement = replacement
    }
}

private struct CompactNowPlayingReplacement: View {
    @Namespace private var animationNamespaceStub
    @Binding var expanded: Bool
    var body: some View {
        ZStack(alignment: .top) {
            NowPlayingBackground(
                colors: [],
                expanded: false,
                isFullExpanded: false,
                canBeExpanded: false
            )
            CompactNowPlaying(
                expanded: $expanded,
                hideArtworkOnExpanded: false,
                animationNamespace: animationNamespaceStub
            )
        }
        .padding(.horizontal, 12)
        .padding(.bottom, ViewConst.compactNowPlayingHeight)
    }
}

#Preview {
    AppView()
}
