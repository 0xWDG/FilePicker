//
//  FilePickerTests.swift
//  FilePicker
//
//  Created by Wesley de Groot on 2025-01-31.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/FilePicker
//  MIT License
//

#if canImport(Testing)
import Foundation
import Testing
@testable import FilePicker

@Test func temporaryFileSanitizesFileNameAndWritesData() throws {
    let data = Data("FilePicker".utf8)
    let temporaryFile = try FilePickerTemporaryFile(
        data: data,
        fileName: "../unsafe.txt",
        types: [.text]
    )
    defer {
        temporaryFile.remove()
    }

    #expect(temporaryFile.url.lastPathComponent == "unsafe.txt")
    #expect(try Data(contentsOf: temporaryFile.url) == data)
}

@Test func temporaryFileUsesPreferredExtensionAndRemovesDirectory() throws {
    let temporaryFile = try FilePickerTemporaryFile(
        data: Data(),
        fileName: nil,
        types: [.plainText]
    )
    let directoryURL = temporaryFile.url.deletingLastPathComponent()

    #expect(temporaryFile.url.pathExtension == "txt")
    #expect(FileManager.default.fileExists(atPath: directoryURL.path))

    temporaryFile.remove()

    #expect(!FileManager.default.fileExists(atPath: directoryURL.path))
}
#endif
