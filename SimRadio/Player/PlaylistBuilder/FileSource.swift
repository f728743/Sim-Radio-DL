//
//  FileSource.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 01.02.2025.
//

import Foundation

struct AudioFile {
    let tag: String?
    let url: URL
    let duration: Double
    let attaches: [AudioFile]

    init(
        baseUrl: URL,
        model: SimRadio.File
    ) {
        tag = model.tag
        var fileUrl = baseUrl
        fileUrl.appendPathComponent(model.path)
        url = fileUrl
        duration = model.audibleDuration ?? model.duration
        attaches = model.attaches?.files.map {
            AudioFile(baseUrl: baseUrl, model: $0)
        } ?? []
    }
}

typealias AudioFileGroups = [String: [AudioFile]]

protocol FileSource {
    func next(parentFile: AudioFile?) -> AudioFile?
}

struct ParticularFileSource: FileSource {
    let file: AudioFile

    func next(parentFile _: AudioFile?) -> AudioFile? {
        return file
    }
}

struct AttachedFileSource: FileSource {
    func next(parentFile: AudioFile?) -> AudioFile? {
        if let file = parentFile, file.attaches.count > 0 {
            return file.attaches[Int(.rand48() * Double(file.attaches.count))]
        }
        return nil
    }
}

struct GroupFileSource: FileSource {
    var randomfiles: RandomFilePick

    init?(files: [AudioFile]) {
        guard let files = RandomFilePick(from: files, withDontRepeatRatio: 3.0 / 7.0) else {
            return nil
        }
        randomfiles = files
    }

    func next(parentFile _: AudioFile?) -> AudioFile? {
        return randomfiles.next()
    }
}

class RandomFilePick {
    private var discardPile: [AudioFile] = []
    private var draw: [AudioFile] = []
    private let maxDiscardPileCount: Int

    init?(from: [AudioFile], withDontRepeatRatio: Double) {
        maxDiscardPileCount = max(1, Int(withDontRepeatRatio * Double(from.count)))
        if from.count < 2 {
            return nil
        }
        draw = from
    }

    func next() -> AudioFile {
        let index = Int(.rand48() * Double(draw.count))
        let res = draw[index]

        discardPile.append(res)
        draw.remove(at: index)
        if discardPile.count > maxDiscardPileCount {
            let putBack = discardPile[0]
            discardPile.remove(at: 0)
            draw.append(putBack)
        }
        return res
    }
}

func makeFileSource(model: SimRadio.Source, fileGroups: AudioFileGroups) -> FileSource? {
    switch model.type {
    case .file:
        guard
            let fileTag = model.fileTag,
            let groupTag = model.groupTag,
            let files = fileGroups[groupTag],
            let file = files.first(where: { $0.tag == fileTag })
        else { return nil }
        return ParticularFileSource(file: file)

    case .group:
        guard
            let groupTag = model.groupTag,
            let files = fileGroups[groupTag]
        else { return nil }
        return GroupFileSource(files: files)

    case .attach:
        return AttachedFileSource()
    }
}
