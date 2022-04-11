//
//  Console.swift
//  Copyright © 2016 Grant Davis Interactive, LLC. All rights reserved.
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
