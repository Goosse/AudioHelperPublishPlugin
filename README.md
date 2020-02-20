# Audio Helper Publish Plugin
## Installation

To install it into your [Publish](https://github.com/johnsundell/publish) package, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(url: "https://github.com/Goosse/AudioHelperPublishPlugin.git", from: "0.1.0")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                ...
                "AudioHelperPublishPlugin"
            ]
        )
    ]
    ...
)
```

Then import AudioHelperPublishPlugin wherever you’d like to use it:

```swift
import AudioHelperPublishPlugin
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

## Usage

The plugin can then be used within any publishing pipeline like this:

```swift
import AudioHelperPublishPlugin
...
try DeliciousRecipes().publish(using: [
    .installPlugin(.addAudioByteSize()),
    .installPlugin(.addAudioDuration())
    ...
])
```

It is actually split out into two different plugins for `Audio.byteSize` and `Audio.duration` to give you more control if you choose to use only one or the other.
