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
            updateViews()
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
        
        audioPlayer = AVAudioPlayer()
        saveAudioCommentButton.isEnabled = false
    }
    
    func updateViews() {
        playButton.isEnabled = !isRecording
        recordButton.isEnabled = !isPlaying
        timeSlider.isEnabled = !isRecording
        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        
        if !isRecording {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime
            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)
            timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
        } else {
            let elapsedTime = audioRecorder?.currentTime ?? 0
            timeElapsedLabel.text = "--:--"
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0
            timeRemainingLabel.text = timeIntervalFormatter.string(from: elapsedTime)!
        }
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
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
    //MARK: - Audio Playback Methods
    
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
            return
        }
    }
    
    private func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    //MARK: - Audio Recording Methods
    
    func startRecording() {
        // try to prepare audio session
        do {
            try prepareAudioSession()
        } catch {
            print("We could not record audio: \(error)")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.record()
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            saveAudioCommentButton.isEnabled = false
            updateViews()
            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }
    
    func createNewRecordingURL() -> URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
            let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
            
//        print("recording URL: \(file)")
        
        return file
        }
        
        
        func requestPermissionOrStartRecording() {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    guard granted == true else {
                        print("We need microphone access")
                        return
                    }
                    
                    print("Recording permission has been granted!")
                    // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
                }
            case .denied:
                print("Microphone access has been blocked.")
                
                let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                present(alertController, animated: true, completion: nil)
            case .granted:
                startRecording()
            @unknown default:
                break
            }
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


extension AddAudioCommentViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            saveAudioCommentButton.isEnabled = true
        }
        audioRecorder = nil
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}
