import Publish
import Foundation
import Files
import AVFoundation

// MARK: Audio.byteSize
//This plugin automatically adds the required Audio.duration and Audio.byteSize variables
public extension Plugin {
    static func addAudioByteSize() -> Self {
        Plugin(name: "Audio Byte Size Calculator") { context in
            let itemContext = context
            context.mutateAllSections { section in
                section.mutateItems { item in
                    
                    if let audio = item.audio {
                        do{
                            let file = try itemContext.file(at: Path(audio.url.path))
                            
                            do {
                                item.audio?.byteSize = try getAudioByteSize(file: file)
                            } catch {
                                print("Audio Byte Size Error:Unable to determine required byteSize for audio at \(audio.url.absoluteString)")
                            }
                            
                        } catch {
                            print("Audio Byte Size Error: Unable to find file at \(audio.url.absoluteString)")
                        }
                    }
                }
            }
        }
    }
}

func getAudioByteSize(file:File) throws -> Int? {
    return try file.url.resourceValues(forKeys:[.fileSizeKey]).fileSize
}

// MARK: - Audio.duration
//This plugin automatically adds the required Audio.duration variable
public extension Plugin {
    static func addAudioDuration() -> Self {
        Plugin(name: "Audio Duration Calculator") { context in
            let itemContext = context
            context.mutateAllSections { section in
                section.mutateItems { item in
                    
                    if let audio = item.audio {
                        do{
                            let file = try itemContext.file(at: Path(audio.url.path))
                            item.audio?.duration = getAudioDuration(file: file)
                            
                        } catch {
                            print("Audio Duration Error: Unable to find file at \(audio.url.absoluteString)")
                        }
                    }
                }
            }
        }
    }
}
    
    func getAudioDuration(file:File) -> Audio.Duration {
        
        let audioAsset = AVURLAsset.init(url: file.url, options: nil)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(durationInSeconds))
        print("The duration is: \(h):\(m):\(s)")
        return Audio.Duration(hours:h, minutes:m, seconds: s)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }


