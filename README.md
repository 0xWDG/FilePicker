# FilePicker

FilePicker is a SwiftUI view modifier that allows you to open a file picker and select a file from the user's device.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FFilePicker%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/FilePicker)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FFilePicker%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/FilePicker)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/FilePicker)

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 15+, macOS 12+

## Installation (Pakage.swift)

```swift
dependencies: [
    .package(url: "https://github.com/0xWDG/FilePicker.git", branch: "main"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "FilePicker", package: "FilePicker"),
    ]),
]
```

## Installation (Xcode)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/0xWDG/FilePicker`) and click **Next**.
3. Click **Finish**.

## Usage

```swift
import SwiftUI
import FilePicker

struct ContentView: View {
    // MARK: Filepicker
    @State var filePickerOpen = false
    @State var filePickerFiles: [URL] = []

    var body: some View {
        VStack {
            Text("Open a file :)")
                .padding()

            Button("Open", systemImage: "square.and.arrow.down") {
                filePickerOpen.toggle()
            }

            ForEach(filePickerFiles, id: \.self) { file in
                Text(file.lastPathComponent)
            }
        }
        .padding()
        .filePicker(
            isPresented: $filePickerOpen,
            files: $filePickerFiles,
            types: [.json, .text], // Optional (default: .json)
            allowsMultipleSelection: false // Optional (default: false)
        )
        .onChange(of: $filePickerFiles.wrappedValue) { newValue in
            print(newValue)
        }
    }
}
```

## Contact

🦋 [@0xWDG](https://bsky.app/profile/0xWDG.bsky.social)
🐘 [mastodon.social/@0xWDG](https://mastodon.social/@0xWDG)
🐦 [@0xWDG](https://x.com/0xWDG)
🧵 [@0xWDG](https://www.threads.net/@0xWDG)
🌐 [wesleydegroot.nl](https://wesleydegroot.nl)
🤖 [Discord](https://discordapp.com/users/918438083861573692)

Interested learning more about Swift? [Check out my blog](https://wesleydegroot.nl/blog/).
