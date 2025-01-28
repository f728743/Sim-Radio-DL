//
//  PlaylistBuilder.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 28.01.2025.
//

import Foundation

enum LibraryError: Error {
    case playlistError
    case fileNotFound(url: URL)
    case compositionCreatingError
}

enum PlaylistError: Error {
    case wrongCondition
    case fragmentNotFound(tag: String)
    case notExhaustiveFragment(tag: String)
    case wrongPositionTag(tag: String)
    case wrongSource
}

extension Double {
    static func rand48() -> Double {
        // swiftlint:disable legacy_random
        drand48()
        // swiftlint:enable legacy_random
    }
}

class PlaylistBuilder {
    let baseUrl: URL
    let commonFiles: [SimRadio.FileGroup]
    let station: SimRadio.Station

    init(
        baseUrl: URL,
        commonFiles: [SimRadio.FileGroup],
        station: SimRadio.Station
    ) {
        self.baseUrl = baseUrl
        self.commonFiles = commonFiles
        self.station = station
    }

    func makePlaylist(duration: TimeInterval) throws -> [AudioComponent] {
        let rules = try PlaylistRules(model: station.playlist, fileGroups: fileGroups)

        var result: [AudioComponent] = []
        var moment: Double = 0
        var fragmentTag = station.playlist.firstFragment.fragmentTag

        var nextFragmentTag = try getNextFragmentTag(after: fragmentTag, rules: rules)

        while moment < duration {
            let fragment = try makeFragment(
                tag: fragmentTag,
                nextTag: nextFragmentTag,
                starts: moment,
                model: rules
            )
            result.append(fragment)
            moment += fragment.playing.duration
            fragmentTag = nextFragmentTag
            nextFragmentTag = try getNextFragmentTag(after: fragmentTag, rules: rules)
        }
        return result
    }
}

private extension PlaylistBuilder {
    var fileGroups: AudioFileGroups {
        let stationBaseUrl: URL = baseUrl.appendingPathComponent(station.tag)
        let stationFiles = convert(files: station.fileGroups, baseUrl: stationBaseUrl)
        let commonFiles = convert(files: commonFiles, baseUrl: baseUrl)
        return stationFiles.merging(commonFiles, uniquingKeysWith: { first, _ in first })
    }

    func convert(files: [SimRadio.FileGroup], baseUrl: URL) -> AudioFileGroups {
        Dictionary(
            uniqueKeysWithValues: files.map {
                let fileList = $0.files.map {
                    AudioFile(baseUrl: baseUrl, model: $0)
                }
                return ($0.tag, fileList)
            }
        )
    }

    func getNextFragmentTag(after fragmentTag: String, rules: PlaylistRules) throws -> String {
        guard let fragment = rules.fragments[fragmentTag] else {
            throw PlaylistError.fragmentNotFound(tag: fragmentTag)
        }
        let rnd = Double.rand48()
        var p = 0.0
        for next in fragment.nextFragment {
            p += next.probability ?? 1.0
            if rnd <= p {
                return next.fragmentTag
            }
        }
        throw PlaylistError.notExhaustiveFragment(tag: fragmentTag)
    }

    func makeFragment(
        tag: String,
        nextTag: String,
        starts sec: Double,
        model: PlaylistRules
    ) throws -> AudioComponent {
        guard let fragment = model.fragments[tag] else {
            throw PlaylistError.fragmentNotFound(tag: tag)
        }

        guard let file = fragment.src.next(parentFile: nil) else {
            throw PlaylistError.wrongSource
        }
        let mixes = try makeFragmentMixin(
            to: file,
            starts: sec,
            at: fragment.mixPositions,
            mixins: fragment.mixins,
            nextTag: nextTag
        )
        let range = TimeRange(
            start: sec,
            duration: file.duration
        )
        return AudioComponent(url: file.url, playing: range, mixes: mixes)
    }

    func makeFragmentMixin(
        to file: AudioFile,
        starts sec: Double,
        at positions: [String: Double],
        mixins: [PlaylistRules.Mix],
        nextTag: String
    ) throws -> [AudioComponent] {
        var usedPositions: Set<String> = []
        var res: [AudioComponent] = []
        for mix in mixins where mix.condition.isSatisfied(forNextFragment: nextTag, startingFrom: sec) == true {
            for posTag in mix.positions {
                if usedPositions.contains(posTag) {
                    continue
                }
                guard let pos = positions[posTag] else {
                    throw PlaylistError.wrongPositionTag(tag: posTag)
                }
                if let mixFile = mix.src.next(parentFile: file) {
                    let t = file.duration - mixFile.duration
                    let mixStartsSec = sec + t * pos
                    let range = TimeRange(
                        start: mixStartsSec,
                        duration: mixFile.duration
                    )
                    res.append(AudioComponent(url: mixFile.url, playing: range, mixes: []))
                    usedPositions.insert(posTag)
                    break
                }
            }
        }
        return res.sorted { $0.playing.start < $1.playing.start }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

func urlTail(_ url: URL) -> String {
    let pattern = #".+\/(.+\/.+)"#
    let urlString = url.absoluteString
    let regex = try? NSRegularExpression(pattern: pattern)
    if let match = regex?.firstMatch(
        in: urlString,
        options: [],
        range: NSRange(location: 0, length: urlString.utf16.count)
    ) {
        if let tailRange = Range(match.range(at: 1), in: urlString) {
            return String(urlString[tailRange])
        }
    }
    return urlString
}

struct TimeRange {
    var start: TimeInterval = 0
    var duration: TimeInterval = 0

    var end: TimeInterval {
        start + duration
    }
}

struct AudioComponent {
    let url: URL
    let playing: TimeRange
    let mixes: [AudioComponent]
}

extension AudioComponent: CustomStringConvertible {
    func description(nesting: Int) -> String {
        let from = playing.start.rounded(toPlaces: 2)
        let to = (playing.start + playing.duration).rounded(toPlaces: 2)
        let indent = String(repeating: "  ", count: nesting)
        return [
            "\(indent)(\(from)..\(to)): \(urlTail(url))",
            mixes.description(nesting: nesting + 1)
        ].joined(separator: "\n")
    }

    var description: String {
        description(nesting: 0)
    }
}

extension Array where Element == AudioComponent {
    func description(nesting: Int) -> String {
        map { $0.description(nesting: nesting) }.joined(separator: "")
    }

    var description: String {
        map(\.description).joined(separator: "")
    }
}

private class PlaylistRules {
    let fileGroups: AudioFileGroups
    let firstFragmentTag: String
    let fragments: [String: Fragment]

    init(
        model: SimRadio.Playlist,
        fileGroups: AudioFileGroups
    ) throws {
        firstFragmentTag = model.firstFragment.fragmentTag
        fragments = try Dictionary(uniqueKeysWithValues: model.fragments.map {
            try ($0.tag, Fragment(model: $0, fileGroups: fileGroups))
        })
        self.fileGroups = fileGroups
    }

    struct Mix {
        var src: FileSource
        let condition: SimRadio.Conditon
        var positions: [String]

        init(
            model: SimRadio.Mix,
            fileGroups: AudioFileGroups
        ) throws {
            guard let src = makeFileSource(model: model.src, fileGroups: fileGroups) else {
                throw PlaylistError.wrongSource
            }
            self.src = src
            condition = model.condition
            positions = model.posVariant.map { $0.posTag }
        }
    }

    struct Fragment {
        let src: FileSource
        let nextFragment: [SimRadio.FragmentRef]
        let mixPositions: [String: Double] // TODO: get rid
        let mixins: [Mix]

        init(
            model: SimRadio.Fragment,
            fileGroups: AudioFileGroups
        ) throws {
            guard let src = makeFileSource(model: model.src, fileGroups: fileGroups) else {
                throw PlaylistError.wrongSource
            }
            self.src = src
            nextFragment = model.nextFragment
            mixPositions = model.mixins == nil ? [:] :
                Dictionary(uniqueKeysWithValues: model.mixins!.pos.map { ($0.tag, $0.relativeOffset) })
            mixins = model.mixins == nil ? [] : try model.mixins!.mix.map { try Mix(model: $0, fileGroups: fileGroups) }
        }
    }
}
