//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var audioData: Data?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
//        guard let audioData = audioData else { return }
//
//        if let url = audioCommentURL {
//
//            do {
//                let audio = try AVAudioPlayer(contentsOf: url)
//                audio.prepareToPlay()
//                audio.play()
//            } catch {
//                print("Error playing audio data from file: \(error)")
//            }
//
//        } else {
//            audioCommentURL = createNewRecordingURL()
//
//            do {
//                try audioData.write(to: audioCommentURL!)
//            } catch {
//                print("Error writing audio data to file: \(error)")
//            }
//            
//            do {
//                let audio = try AVAudioPlayer(contentsOf: audioCommentURL!)
//                audio.prepareToPlay()
//                audio.play()
//            } catch {
//                print("Error playing audio data from file: \(error)")
//            }
//        }
    }
    
//    func createNewRecordingURL() -> URL {
//        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
//        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
//
//    return file
//    }

}
