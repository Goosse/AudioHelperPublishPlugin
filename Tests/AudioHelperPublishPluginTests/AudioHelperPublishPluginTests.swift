import XCTest
import Files
import Foundation
import Publish
import Plot

@testable import AudioHelperPublishPlugin

// MARK: - TestWebsite
private struct TestWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        case test
    }
    
    struct ItemMetadata: PodcastCompatibleWebsiteItemMetadata {
        var podcast: PodcastEpisodeMetadata?
        var audio: Audio?
        
        init(podcast: PodcastEpisodeMetadata?, audio: Audio?) {
            self.podcast = podcast
            self.audio = audio
        }
    }
    
    var url = URL(string: "http://example.com")!
    var name = "test"
    var description = ""
    var language: Language { .english }
    var imagePath: Path? = nil
}

final class AudioHelperPublishPluginTests: XCTestCase {
    
    private static var testDirPath: Path {
        let sourceFileURL = URL(fileURLWithPath: #file)
        
        return Path(sourceFileURL.deletingLastPathComponent().path)
    }
    
    private static func testAudioFile() throws -> File {
        let sourceFileURL = URL(fileURLWithPath: #file)
        
        return try File(path:"\(sourceFileURL.deletingLastPathComponent().path)/Resources/test.mp3")
    }
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
     
     //try? Folder(path: Self.testDirPath.appendingComponent("Output").absoluteString).delete()
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? Folder(path: Self.testDirPath.appendingComponent("Output").absoluteString).delete()
        try? Folder(path: Self.testDirPath.appendingComponent(".publish").absoluteString).delete()
    }
    
    // MARK: - Tests
    
    func testAudioDuration() {
        
        do{
            let audioDuration = getAudioDuration(file: try Self.testAudioFile())
            
            XCTAssertEqual(audioDuration.hours, 1)
            XCTAssertEqual(audioDuration.minutes, 3)
            XCTAssertEqual(audioDuration.seconds, 18)
            
            
        } catch{
            XCTFail("test.mp3 does not exist for testing audio duration")
        }
        
    }
    
    func testAudioByteSize() {
        
        do{
            let file = try Self.testAudioFile()
            do{
                let audioByteSize = try getAudioByteSize(file: file)
                XCTAssertEqual(audioByteSize, 7596561)
                
            } catch{
                XCTFail("Failed to retrieve .fileSizeKey for resource at \(file.path)")
            }
            
        } catch{
            XCTFail("test.mp3 does not exist for testing audio byteSize")
        }
        
    }
    
    func testMutatingItemAudioOnPublish() throws {
        
        guard let url = URL(string: "Resources/test.mp3") else {
            XCTFail("test.mp3 does not exist for testing mutating item audio info on publish .")
            return
        }
            
        let metadata = TestWebsite.ItemMetadata(
            podcast: PodcastEpisodeMetadata(episodeNumber: 1, seasonNumber: 1, isExplicit: false),
            audio: nil)
        
        let site = try TestWebsite().publish(at: Self.testDirPath, using: [
            .addItem(
                Item<TestWebsite>(
                    path: "item",
                    sectionID: .test,
                    metadata: metadata,
                    tags: ["tag"],
                    content: Content(
                        date: Date(),
                        lastModified: Date(),
                        audio: Audio(url: url)
                ))),
            .installPlugin(.addAudioByteSize()),
            .installPlugin(.addAudioDuration())
        ])
        
        let item = try require(site.sections[.test].item(at: "item"))
        
        guard let itemAudio = item.audio else {
            XCTAssertNotNil(item.audio)
            return
        }
        
        XCTAssertEqual(itemAudio.byteSize, 7596561)
        
        XCTAssertNotNil(itemAudio.duration)
        
        if let duration = itemAudio.duration {
            XCTAssertEqual(duration.hours, 1)
            XCTAssertEqual(duration.minutes, 3)
            XCTAssertEqual(duration.seconds, 18)
        }
    }
    
    static var allTests = [
        ("testAudioDuration", testAudioDuration),
        ("testAudioByteSize", testAudioByteSize),
        ("testMutatingItemOnPublish", testMutatingItemAudioOnPublish),
    ]
}
