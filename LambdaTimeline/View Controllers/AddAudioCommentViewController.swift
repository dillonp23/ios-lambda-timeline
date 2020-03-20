//
//  AddAudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AddAudioCommentViewController: UIViewController {
    
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveAudioCommentButton: UIButton!

    var delegate: AddAudioCommentDelegate?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            
        }
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use a font that won't jump around as values change
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
    }
    
    //MARK: - Actions

    @IBAction func saveButtonTapped(_ sender: Any) {
        // TODO: Use the newly recorded audio comments url to update post's comments
        if let url = URL(string: "testURL") {
            delegate?.addAudiComment(audioURL: url)
        }
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    //MARK: - Private Functions
    
    private func play() {
        audioPlayer?.play()
    }
    
    private func pause() {
        audioPlayer?.pause()
    }

}
