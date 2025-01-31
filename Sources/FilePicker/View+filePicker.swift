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
    @ViewBuilder
    public func filePicker(
        isPresented: Binding<Bool>,
        files: Binding<[URL]>,
        types: [UTType] = [.text],
        allowMultiple: Bool = false
    ) -> some View {
        sheet(isPresented: isPresented) {
#if os(iOS)
            FilePickerUIRepresentable(types: types, allowMultiple: allowMultiple) { urls in
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
}
#endif
