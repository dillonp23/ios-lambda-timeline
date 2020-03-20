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
    @IBOutlet weak var timeSlider: UISlider!
    
    var delegate: AddAudioCommentDelegate?
    
    //MARK: - AV Variables
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
        }
    }

    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    
    //MARK: - Current State
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    
    //MARK: - Timer & Date Formatter
    weak var timer: Timer?
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use a font that won't jump around as values change
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        updateViews()
    }
    
    func updateViews() {
        playButton.isSelected = isPlaying
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        let timeRemaining = duration.rounded() - elapsedTime
        
        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
        
        timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
    }
    
    deinit {
        timer?.invalidate()
    }
    
    
    // MARK: - Timer
    
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
//            if let audioRecorder = self.audioRecorder,
//                self.isRecording == true {
//
//                audioRecorder.updateMeters()
//                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))
//
//            }
            
//            if let audioPlayer = self.audioPlayer,
//                self.isPlaying == true {
//
//                audioPlayer.updateMeters()
//                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
//            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
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
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }
        
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateViews()
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
    
    //MARK: - Private Functions
    
    func loadAudio() {
        
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    private func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Error preparing audio session: \(error)")
        }
    }
    
    private func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }

}

extension AddAudioCommentViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error decoding audio: \(error)")
        }
    }
    
}
