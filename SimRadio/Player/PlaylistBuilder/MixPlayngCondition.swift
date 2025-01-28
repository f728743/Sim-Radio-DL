//
//  MixPlayngCondition.swift
//  SimRadio
//
//  Created by Alexey Vorobyov on 28.01.2025.
//

import Foundation

protocol MixPlayngCondition {
    func isSatisfied(forNextFragment tag: String, startingFrom second: TimeInterval) -> Bool?
}

extension SimRadio.Conditon: MixPlayngCondition {
    func isSatisfied(forNextFragment tag: String, startingFrom second: TimeInterval) -> Bool? {
        switch type {
        case .nextFragment:
            isSatisfied(nextFragment: tag)
        case .random:
            isSatisfiedRandom()
        case .groupAnd:
            isGroupAndSatisfied(nextFragment: tag, starts: second)
        case .groupOr:
            isGroupOrSatisfied(nextFragment: tag, starts: second)
        case .timeInterval:
            isSatisfiedАForTimeInterval(starts: second)
        }
    }

    func isSatisfied(nextFragment tag: String) -> Bool? {
        guard let next = fragmentTag else { return nil }
        return next == tag
    }

    func isSatisfiedRandom() -> Bool? {
        guard let probability else { return nil }
        return .rand48() <= probability
    }

    func isGroupAndSatisfied(nextFragment tag: String, starts sec: TimeInterval) -> Bool? {
        guard let condition, condition.count > 1 else { return nil }
        return condition.firstIndex { $0.isSatisfied(forNextFragment: tag, startingFrom: sec) == false } == nil
    }

    func isGroupOrSatisfied(nextFragment tag: String, starts sec: TimeInterval) -> Bool? {
        guard let condition, condition.count > 1 else { return nil }
        return condition.firstIndex { $0.isSatisfied(forNextFragment: tag, startingFrom: sec) == true } != nil
    }

    func isSatisfiedАForTimeInterval(starts sec: TimeInterval) -> Bool? {
        guard let from = from.map({ secOfDay(hhmm: $0) }) ?? nil,
              let to = to.map({ secOfDay(hhmm: $0) }) ?? nil
        else {
            return nil
        }
        return from <= sec && sec <= to
    }
}

private func secOfDay(hhmm: String) -> Double? {
    let time = hhmm.split { $0 == ":" }.map(String.init)
    guard time.count > 1 else {
        return nil
    }

    guard let h = Double(time[0]), let m = Double(time[1]) else {
        return nil
    }
    return (h * 60 * 60) + (m * 60)
}
