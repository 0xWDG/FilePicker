//
//  FilePicker.swift
//  FilePicker
//
//  Created by Wesley de Groot on 2025-01-31.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/FilePicker
//  MIT License
//

#if os(iOS) && canImport(SwiftUI) && canImport(UniformTypeIdentifiers)
import SwiftUI
import UniformTypeIdentifiers

/// FilePickerUIRepresentable
///
/// This is a wrapper for `UIDocumentPickerViewController`
public struct FilePickerUIRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    public typealias PickerCompletion = (_ urls: [URL]) -> Void

    public let data: Data?
    public let fileName: String?
    public let types: [UTType]
    public let allowMultiple: Bool
    public let pickedCompletionHandler: PickerCompletion

    /// Initialize FilePickerUIRepresentable
    /// 
    /// - Parameter types: Allowed file types
    /// - Parameter allowMultiple: Allow selecting multiple files
    /// - Parameter data: Data to save (if empty we're picking files)
    /// - Parameter completionHandler: The completion handler (aka returned items)
    public init(
        types: [UTType],
        allowMultiple: Bool,
        fileName: String?,
        data: Data?,
        onPicked completionHandler: @escaping PickerCompletion
    ) {
        self.data = data
        self.fileName = fileName
        self.types = types
        self.allowMultiple = allowMultiple
        self.pickedCompletionHandler = completionHandler
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        var picker: UIDocumentPickerViewController

        if let data {
            var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())

            if let fileName {
                tempURL = tempURL.appendingPathComponent(fileName)
            } else {
                tempURL = tempURL
                    .appendingPathComponent("File")
                    .appendingPathExtension(types.first?.preferredFilenameExtension ?? "tmp")
            }

            do {
                try data.write(to: tempURL)
                picker = UIDocumentPickerViewController(forExporting: [tempURL])
            } catch {
                fatalError("Failed to write data to temp file: \(error)")
            }
        } else {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
            picker.allowsMultipleSelection = allowMultiple
        }

        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerUIRepresentable

        init(parent: FilePickerUIRepresentable) {
            self.parent = parent
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.pickedCompletionHandler(urls)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// FPExport
#endif
