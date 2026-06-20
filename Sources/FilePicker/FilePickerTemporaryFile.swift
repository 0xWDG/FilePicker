//
//  FilePickerTemporaryFile.swift
//  FilePicker
//
//  Created by Wesley de Groot on 2026-06-14.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/FilePicker
//  MIT License
//

#if canImport(UniformTypeIdentifiers)
import Foundation
import UniformTypeIdentifiers

struct FilePickerTemporaryFile {
    let url: URL

    private let directoryURL: URL

    init(data: Data, fileName: String?, types: [UTType]) throws {
        let fileManager = FileManager.default
        let directoryURL = fileManager.temporaryDirectory
            .appendingPathComponent("FilePicker", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let safeFileName = fileName.map { URL(fileURLWithPath: $0).lastPathComponent } ?? ""
        let resolvedFileName = safeFileName.isEmpty
            ? "File.\(types.first?.preferredFilenameExtension ?? "tmp")"
            : safeFileName
        let url = directoryURL.appendingPathComponent(resolvedFileName, isDirectory: false)

        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            try? fileManager.removeItem(at: directoryURL)
            throw error
        }

        self.url = url
        self.directoryURL = directoryURL
    }

    func remove() {
        try? FileManager.default.removeItem(at: directoryURL)
    }
}
#endif
