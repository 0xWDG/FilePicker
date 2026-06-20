//
//  View+filePicker.swift
//  FilePicker
//
//  Created by Wesley de Groot on 2025-01-31.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/FilePicker
//  MIT License
//

#if canImport(SwiftUI) && canImport(UniformTypeIdentifiers)
import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    /// Display a file picker
    ///
    /// FilePicker is a SwiftUI view modifier that allows you
    /// to open a file picker and select a file from the user's device.
    ///
    /// - Parameters:
    ///   - isPresented: Is the picker presented?
    ///   - files: Files selected
    ///   - types: Allowed file types
    ///   - allowMultiple: Allow selecting multiple files
    /// - Returns: view
    ///
    /// Example (open file)
    /// ```swift
    /// struct ContentView: View {
    ///     @State var filePickerOpen = false
    ///     @State var filePickerFiles: [URL] = []
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Open File Picker") {
    ///                 filePickerOpen.toggle()
    ///             }
    ///             .filePicker(
    ///                 isPresented: $filePickerOpen,
    ///                 files: $filePickerFiles,
    ///                 types: [.text]
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    @ViewBuilder
    public func filePicker(
        isPresented: Binding<Bool>,
        files: Binding<[URL]>,
        types: [UTType] = [.text],
        allowMultiple: Bool = false
    ) -> some View {
        fileImporter(
            isPresented: isPresented,
            allowedContentTypes: types.filePickerContentTypes,
            allowsMultipleSelection: allowMultiple
        ) { result in
            if case let .success(urls) = result {
                files.wrappedValue = urls
            }

            isPresented.wrappedValue = false
        }
    }

    /// Display a file picker
    ///
    /// FilePicker is a SwiftUI view modifier that allows you
    /// to open a file picker and select a file from the user's device.
    ///
    /// - Parameters:
    ///   - isPresented: Is the picker presented?
    ///   - files: Files selected
    ///   - types: Allowed file types
    ///   - allowMultiple: Allow selecting multiple files
    /// - Returns: view
    ///
    /// Example (save file)
    /// ```swift
    /// struct ContentView: View {
    ///     @State var filePickerOpen = false
    ///     var filePickerFileName = "example.txt"
    ///     var filePickerData = Data("Hello, World!".utf8)
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Save File Picker") {
    ///                 filePickerOpen.toggle()
    ///             }
    ///             .filePicker(
    ///                 isPresented: $filePickerOpen,
    ///                 fileName: filePickerFileName,
    ///                 data: filePickerData,
    ///                 types: [.text]
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    @ViewBuilder
    public func filePicker(
        isPresented: Binding<Bool>,
        fileName: String,
        data: Data,
        types: [UTType] = [.text],
        allowMultiple: Bool = false
    ) -> some View {
        fileExporter(
            isPresented: isPresented,
            document: FilePickerDocument(data: data),
            contentType: types.filePickerExportContentType,
            defaultFilename: URL(fileURLWithPath: fileName).lastPathComponent
        ) { _ in
            isPresented.wrappedValue = false
        }
    }
}

private struct FilePickerDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.data]
    }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

private extension [UTType] {
    var filePickerContentTypes: [UTType] {
        isEmpty ? [.data] : self
    }

    var filePickerExportContentType: UTType {
        filePickerContentTypes.first ?? .data
    }
}
#endif
