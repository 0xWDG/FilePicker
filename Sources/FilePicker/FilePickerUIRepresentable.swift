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
    @Environment(\.dismiss) private var dismiss

    public typealias PickerCompletion = (_ urls: [URL]) -> Void
    public typealias ErrorCompletion = (_ error: Error) -> Void

    public let data: Data?
    public let fileName: String?
    public let types: [UTType]
    public let allowMultiple: Bool
    public let pickedCompletionHandler: PickerCompletion
    public let cancellationHandler: () -> Void
    public let errorCompletionHandler: ErrorCompletion

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
        onPicked completionHandler: @escaping PickerCompletion,
        onCancel cancellationHandler: @escaping () -> Void = {},
        onError errorCompletionHandler: @escaping ErrorCompletion = { _ in }
    ) {
        self.data = data
        self.fileName = fileName
        self.types = types
        self.allowMultiple = allowMultiple
        self.pickedCompletionHandler = completionHandler
        self.cancellationHandler = cancellationHandler
        self.errorCompletionHandler = errorCompletionHandler
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        var picker: UIDocumentPickerViewController

        if let data {
            do {
                let temporaryFile = try FilePickerTemporaryFile(data: data, fileName: fileName, types: types)
                context.coordinator.temporaryFile = temporaryFile
                picker = UIDocumentPickerViewController(forExporting: [temporaryFile.url])
            } catch {
                context.coordinator.report(error: error)
                picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
            }
        } else {
            picker = UIDocumentPickerViewController(
                forOpeningContentTypes: types.isEmpty ? [.data] : types,
                asCopy: true
            )
            picker.allowsMultipleSelection = allowMultiple
        }

        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {
        context.coordinator.parent = self
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerUIRepresentable
        var temporaryFile: FilePickerTemporaryFile?

        init(parent: FilePickerUIRepresentable) {
            self.parent = parent
        }

        deinit {
            temporaryFile?.remove()
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.pickedCompletionHandler(urls)
            finish()
        }

        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.cancellationHandler()
            finish()
        }

        func report(error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }

                parent.errorCompletionHandler(error)
                finish()
            }
        }

        private func finish() {
            temporaryFile?.remove()
            temporaryFile = nil
            parent.dismiss()
        }
    }
}

// FPExport
#endif
