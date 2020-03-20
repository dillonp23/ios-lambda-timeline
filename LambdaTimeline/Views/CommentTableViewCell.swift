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
    
    var audioCommentURL: URL?
    var audioPlayer = AVAudioPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        guard let audioURL = audioCommentURL else { return }
       
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            self.audioPlayer.play()
        } catch {
            print("Error playign audio: \(error)")
        }
        
    }

}
