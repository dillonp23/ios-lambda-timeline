//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraView!
    @IBOutlet weak var saveButton: UIButton!
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    var player: AVPlayer!
    var postController: PostController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.videoPlayerLayer.videoGravity = .resizeAspectFill
        setUpCamera()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            replayRecording()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    // MARK: - Camera & Microphone Set Up Methods
    
    private func setUpCamera() {
        let camera = bestCamera()
        let microphone = bestMicrophone()
        
        captureSession.beginConfiguration()
        
        // Check if we have camer and mic available as inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("Cannot get camera input")
        }
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("Cannot get microphone input")
        }
        
        // Add Video input
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("Unable to add camera input")
        }
        captureSession.addInput(cameraInput)
        
        // Add audio input
        guard captureSession.canAddInput(microphoneInput) else {
            preconditionFailure("Unable to add microphone input")
        }
        captureSession.addInput(microphoneInput)
        
        // Set video present
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Check if can output & add output
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("Cannot write to disk")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        preconditionFailure("No camera on device match the necessary specs for recording video")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        preconditionFailure("No microphones on device could be used for recording video")
    }

    
    // MARK: - Button Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a title", message: "Please enter a title for your video post", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let addPostAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            guard let postController = self.postController, let title = alert.textFields?.first?.text else { return }
            print(postController)
            print(title)
            
//            postController.createPost(with: title, ofType: .video, mediaData: <#T##Data#>, ratio: <#T##CGFloat?#>, completion: <#T##(Bool) -> Void#>)
        }
        
        alert.addAction(cancel)
        alert.addAction(addPostAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        toggleRecording()
    }
    
    //MARK: - Video Recording Functions
    
    private func toggleRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    // MARK: - Video Playback Functions
    
    private func replayRecording() {
        if let player = player {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        let playbackView = view.bounds
        
        playerLayer.frame = playbackView
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video to file output: \(error)")
        }
        
        print("Video url: \(outputFileURL)")
        
        updateViews()
        
        playMovie(url: outputFileURL)
    }
    
    
}
