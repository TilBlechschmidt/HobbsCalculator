//
//  Collection+Chunked.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import Foundation

extension Collection {
    public func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        var rest = self[...]
        while !rest.isEmpty {
            chunks.append(rest.prefix(size))
            rest = rest.dropFirst(size)
        }
        return chunks
    }

    public func windows(of size: Int) -> [SubSequence] {
        var windows: [SubSequence] = []
        var rest = self[...]

        while !rest.isEmpty {
            let window = rest.prefix(size)
            if window.count < size { break }
            windows.append(window)
            rest = rest.dropFirst()
        }

        return windows
    }
}
