//
//  SimRadioStation.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 12.01.2025.
//

import Foundation

enum SimRadio {
    struct Series: Codable, Sendable {
        let info: SeriesInfo
        let common: SeriesCommon
        let stations: [Station]
    }

    struct SeriesInfo: Codable {
        let title: String
        let logo: String
    }

    struct SeriesCommon: Codable, Sendable {
        let fileGroups: [FileGroup]
    }

    struct Station: Codable {
        let tag: String
        let info: StationInfo
        let fileGroups: [FileGroup]
        let playlist: Playlist
    }

    struct FileGroup: Codable, Sendable {
        let tag: String
        let files: [File]
    }

    struct File: Codable, Sendable {
        let tag: String?
        let path: String
        let duration: Double
        let audibleDuration: Double?
        let attaches: Attaches?
    }

    struct Attaches: Codable {
        let files: [File]
    }

    struct StationInfo: Codable {
        let title: String
        let genre: String
        let logo: String
        let dj: String?
    }

    struct FirstFragment: Codable {
        let tag: String
    }

    struct FragmentRef: Codable {
        let fragmentTag: String
        let probability: Double?
    }

    struct Source: Codable {
        let type: SrcType
        let groupTag: String?
        let fileTag: String?
    }

    struct Position: Codable {
        let tag: String
        let relativeOffset: Double
    }

    struct PosVariant: Codable {
        let posTag: String
    }

    struct Conditon: Codable {
        let type: ConditionType
        let fragmentTag: String?
        let probability: Double?
        let from: String?
        let to: String?
        let condition: [Conditon]?
    }

    struct Mix: Codable {
        let tag: String
        let src: Source
        let condition: Conditon
        let posVariant: [PosVariant]
    }

    struct Mixin: Codable {
        let pos: [Position]
        let mix: [Mix]
    }

    struct Fragment: Codable {
        let tag: String
        let src: Source
        let nextFragment: [FragmentRef]
        let mixins: Mixin?
    }

    struct Playlist: Codable {
        let firstFragment: FragmentRef
        let fragments: [Fragment]
    }

    enum SrcType: String, Codable {
        case group
        case attach
        case file
    }

    enum ConditionType: String, Codable {
        case nextFragment
        case random
        case groupAnd
        case groupOr
        case timeInterval
    }
}
