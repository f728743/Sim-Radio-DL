//
//  Playlist.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 29.01.2025.
//

import AVFoundation

struct PlayingTime {
    let range: TimeRange
    let positionInComposition: TimeInterval
}

func calcPlayingTime(range: TimeRange, starting from: TimeInterval, withOffset offset: TimeInterval) -> PlayingTime {
    var itemStart: TimeInterval = 0
    if range.start < from {
        itemStart = from - range.start
    }
    let playingRange = TimeRange(start: itemStart, duration: range.duration - itemStart)
    let position = range.start - from + itemStart + offset

    return PlayingTime(range: playingRange, positionInComposition: position)
}

@MainActor
private class PlayerItemLoader {
    enum Destination: String {
        case main
        case mix
    }

    private let fadingDuration: Double = 1.0
    private let normalVolume: Float = 1.0
    private let lowVolume: Float = 0.3

    private var start: CMTime?
    private let composition: AVMutableComposition
    private let audioMix: AVMutableAudioMix
    private let mainTrack: AVMutableCompositionTrack
    private let mixTrack: AVMutableCompositionTrack
    private let params: AVMutableAudioMixInputParameters

    let timescale: CMTimeScale = 1000

    var playerItem: AVPlayerItem {
        audioMix.inputParameters = [params]
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.audioMix = audioMix
        return playerItem
    }

    init() throws {
        composition = AVMutableComposition()
        audioMix = AVMutableAudioMix()
        guard let mainTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw LibraryError.compositionCreatingError
        }
        self.mainTrack = mainTrack
        guard let mixTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw LibraryError.compositionCreatingError
        }
        self.mixTrack = mixTrack
        params = AVMutableAudioMixInputParameters(track: mainTrack)
    }

    func insert(
        _ item: AudioComponent,
        starting from: TimeInterval,
        to destination: Destination,
        withOffset offset: TimeInterval
    ) throws {
        if item.playing.end <= from {
            return
        }
        let playingTime = calcPlayingTime(range: item.playing, starting: from, withOffset: offset)

        let destTrack = destination == .main ? mainTrack : mixTrack
        let asset = AVURLAsset(url: item.url)
        guard let assetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
            throw LibraryError.fileNotFound(url: item.url)
        }
        try destTrack.insertTimeRange(
            .init(range: playingTime.range, scale: timescale),
            of: assetTrack,
            at: .init(seconds: playingTime.positionInComposition, preferredTimescale: timescale)
        )

        if destination == .mix {
            setVolumeRampParams(
                duration: playingTime.range.duration,
                at: playingTime.positionInComposition
            )
        }
    }

    func insert(
        playlist: [AudioComponent],
        from: TimeInterval,
        to: TimeInterval,
        withOffset offset: TimeInterval
    ) throws -> (depleted: Bool, lastRange: TimeRange) {
        var depleted = true
        var lastRange = TimeRange()
        for item in playlist {
            //            print("item \(urlTail(item.url)) \(item.playing.start.seconds.rounded(toPlaces: 2))-" +
            //                "\(item.playing.end.seconds.rounded(toPlaces: 2))")
            if item.playing.start > to {
                depleted = false
                break
            }
            lastRange = item.playing

            try insert(item, starting: from, to: .main, withOffset: offset)
            for mix in item.mixes {
                try insert(mix, starting: from, to: .mix, withOffset: offset)
            }
        }
        return (depleted: depleted, lastRange: lastRange)
    }

    private func setVolumeRampParams(duration: TimeInterval, at insertPosition: TimeInterval) {
        let fadeOutEnd = insertPosition
        let fadeOutStart = fadeOutEnd - fadingDuration
        let fadeInStart = insertPosition + duration
        let fadeInEnd = fadeInStart + fadingDuration

        params.setVolumeRamp(
            fromStartVolume: normalVolume,
            toEndVolume: lowVolume,
            timeRange: CMTimeRange(
                start: CMTime(seconds: fadeOutStart, preferredTimescale: timescale),
                end: CMTime(seconds: fadeOutEnd, preferredTimescale: timescale)
            )
        )

        params.setVolumeRamp(
            fromStartVolume: lowVolume,
            toEndVolume: normalVolume,
            timeRange: CMTimeRange(
                start: CMTime(seconds: fadeInStart, preferredTimescale: timescale),
                end: CMTime(seconds: fadeInEnd, preferredTimescale: timescale)
            )
        )
    }
}

extension CMTimeRange {
    init(range: TimeRange, scale: CMTimeScale) {
        self.init(
            start: CMTime(seconds: range.start, preferredTimescale: scale),
            duration: CMTime(seconds: range.duration, preferredTimescale: scale)
        )
    }
}

@MainActor
class Playlist {
    let baseUrl: URL
    let commonFiles: [SimRadio.FileGroup]
    let station: SimRadio.Station
    let timescale: CMTimeScale = 1000
    var nextPlayerItem: AVPlayerItem?
    var lastPlaying: (range: TimeRange, day: Date)?

    init(
        baseUrl: URL,
        commonFiles: [SimRadio.FileGroup],
        station: SimRadio.Station
    ) throws {
        self.baseUrl = baseUrl
        self.commonFiles = commonFiles
        self.station = station
    }

    func getPlayerItem(
        for day: Date,
        from: TimeInterval,
        minDuraton: TimeInterval
    ) throws -> AVPlayerItem {
        let dayLength: TimeInterval = 24 * 60 * 60
        let to = from + minDuraton
        let playlistBuilder = PlaylistBuilder(
            baseUrl: baseUrl,
            commonFiles: commonFiles,
            station: station
        )
        srand48(Int(day.timeIntervalSince1970))
        let todaysPlaylist = try playlistBuilder.makePlaylist(duration: dayLength)
        let compositor = try PlayerItemLoader()

        let firstPlaylist = try compositor.insert(playlist: todaysPlaylist, from: from, to: to, withOffset: .zero)

        lastPlaying = (range: firstPlaylist.lastRange, day: day)

        if firstPlaylist.depleted {
            let nextDayFrom = firstPlaylist.lastRange.end - dayLength
            let tomorrowsTo = to - dayLength
            let tomorrow = day.dayAfter.startOfDay
            srand48(Int(tomorrow.timeIntervalSince1970))
            let playlistBuilder = PlaylistBuilder(
                baseUrl: baseUrl,
                commonFiles: commonFiles,
                station: station
            )
            let tomorrowsPlaylist = try playlistBuilder.makePlaylist(duration: dayLength)
            let lastPlayingTime = calcPlayingTime(range: firstPlaylist.lastRange, starting: from, withOffset: .zero)
            let offset = lastPlayingTime.range.duration + lastPlayingTime.positionInComposition
            let insertResult = try compositor.insert(
                playlist: tomorrowsPlaylist,
                from: nextDayFrom,
                to: tomorrowsTo,
                withOffset: offset
            )
            lastPlaying = (range: insertResult.lastRange, day: tomorrow)
        }
        return compositor.playerItem
    }

    func prepareNextPlayerItem(minDuraton: TimeInterval) throws {
        guard let lastPlayingEnd = lastPlaying?.range.end, let lastPlayingDay = lastPlaying?.day else {
            throw LibraryError.playlistError
        }
        nextPlayerItem = try getPlayerItem(for: lastPlayingDay, from: lastPlayingEnd, minDuraton: minDuraton)
    }
}
