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
        sheet(isPresented: isPresented) {
#if os(iOS)
            FilePickerUIRepresentable(
                types: types,
                allowMultiple: allowMultiple,
                fileName: nil,
                data: nil
            ) { urls in
                files.wrappedValue = urls
                isPresented.wrappedValue = false
            }
#endif
#if os(macOS)
            ProgressView()
                .task {
                    files.wrappedValue = await withCheckedContinuation { continuation in
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = allowMultiple
                        panel.canChooseDirectories = false
                        panel.canChooseFiles = true
                        panel.allowedContentTypes = types
                        panel.begin { reponse in
                            if reponse == .OK {
                                continuation.resume(returning: panel.urls)
                            } else {
                                continuation.resume(returning: [])
                            }

                            isPresented.wrappedValue = false
                        }
                    }
                }
#endif
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
        sheet(isPresented: isPresented) {
#if os(iOS)
            FilePickerUIRepresentable(
                types: types,
                allowMultiple: allowMultiple,
                fileName: fileName,
                data: data
            ) { urls in
                print(urls)
                isPresented.wrappedValue = false
            }
#endif
#if os(macOS)
            ProgressView()
                .task {
                    let status = await withCheckedContinuation { continuation in
                        let panel = NSSavePanel()
                        panel.nameFieldStringValue = fileName
                        panel.allowedContentTypes = types
                        panel.begin { reponse in
                            if reponse == .OK {
                                if let url = panel.url {
                                    do {
                                        try data.write(to: url)
                                        continuation.resume(returning: true)
                                    } catch {
                                        print("Error", error)
                                        continuation.resume(returning: false)
                                    }
                                } else {
                                    continuation.resume(returning: false)
                                }
                            } else {
                                continuation.resume(returning: false)
                            }

                            isPresented.wrappedValue = false
                        }
                    }
                }
#endif
        }
    }
}
#endif
