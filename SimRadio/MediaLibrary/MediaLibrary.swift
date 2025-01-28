//
//  MediaLibrary.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 27.11.2024.
//

import AVFoundation
import Foundation

actor LibraryManagmentActor {
    func loadSimRadioSeries(url: URL) async throws -> SimRadio.Series {
        let (data, _) = try await URLSession.shared.data(from: url)
        let series = try JSONDecoder().decode(SimRadio.Series.self, from: data)
        return series
    }
}

@MainActor
final class MediaLibrary: ObservableObject {
    var player: AVPlayer?
    var loadManager: LibraryManagmentActor
    @Published var list: [MediaList] = []

    init() {
        loadManager = .init()
    }

    func reload() {
        let baseUrlStr = "https://raw.githubusercontent.com/tmp-acc/GTA-V-Radio-Stations/master"
        let urlStr = "\(baseUrlStr)/sim_radio_stations.json"
        guard let url = URL(string: urlStr) else { return }
        Task {
            do {
                let series = try await loadManager.loadSimRadioSeries(url: url)
                testBuildPlaylist(baseUrlStr: baseUrlStr, series: series)
                list = [.init(from: series, baseUrl: baseUrlStr)]
            } catch {
                print(error)
            }
        }
    }
}

private extension MediaLibrary {
    func currentSecondOfDay() -> Double {
        let now = Date()
        let calendar = Calendar.current

        let h = calendar.component(.hour, from: now)
        let m = calendar.component(.minute, from: now)
        let s = calendar.component(.second, from: now)
        return Double(h * 60 * 60 + m * 60 + s)
    }

    func testBuildPlaylist(baseUrlStr: String, series: SimRadio.Series) {
        guard
            let baseUrl = URL(string: baseUrlStr),
            let station = series.stations.first
        else { return }

        let nowSec = currentSecondOfDay()
        do {
            let playlist = try Playlist(
                baseUrl: baseUrl,
                commonFiles: series.common.fileGroups,
                station: station
            )

            let playerItem = try playlist.getPlayerItem(for: Date().startOfDay, from: nowSec, minDuraton: 3 * 60)
            let player = AVPlayer(playerItem: playerItem)
            player.play()
            self.player = player
        } catch {
            print(error)
        }
    }
}

extension Media {
    init(from station: SimRadio.Station, baseUrl: String) {
        title = station.info.title
        subtitle = station.info.genre
        let artwork = "\(baseUrl)/\(station.tag)/\(station.info.logo)"
        self.artwork = URL(string: artwork)
        online = false
    }
}

extension MediaList {
    init(from series: SimRadio.Series, baseUrl: String) {
        self.init(
            artwork: URL(string: "\(baseUrl)/\(series.info.logo)"),
            title: series.info.title,
            subtitle: nil,
            items: series.stations.map { .init(from: $0, baseUrl: baseUrl) }
        )
    }
}
