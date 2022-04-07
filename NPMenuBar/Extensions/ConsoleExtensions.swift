//
//  ConsoleExtensions.swift
//  MacMenuApp
//
//  Created by Attila Szél on 2022. 04. 05..
//

import Foundation

public extension Sequence where Element: Equatable {
    var unique: [Self.Element] {
        var processed = [Self.Element]()

        return filter {
            if processed.contains($0) { return false }
            processed.append($0)
            return true
        }
    }
}

public extension NSNotification.Name {

    func postOnMainThread(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        let post = { NotificationCenter.default.post(name: self, object: object, userInfo: userInfo) }

        if Thread.isMainThread {
            post()
        } else {
            DispatchQueue.main.async(execute: post)
        }
    }
}
