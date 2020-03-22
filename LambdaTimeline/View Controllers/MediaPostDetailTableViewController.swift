//
//  MediaPostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

protocol AddTextCommentDelegate {
     func addTextComment(text: String)
 }

protocol AddAudioCommentDelegate {
    func addAudioComment(audioURL: URL)
}

class MediaPostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        audioPlayer = AVAudioPlayer()
        
        //TODO: Fix audio playback bug when tapping on cells -> set up playback to be based on play button and disable cell selection in table view
        //        tableView.allowsSelection = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            replayRecording()
        }
    }
    
    private func replayRecording() {
        if playerItem != nil {
            avPlayer.seek(to: CMTime.zero)
            avPlayer.play()
        }
    }
    
    func updateViews() {
        
        if let imageData = imageData,
            let image = UIImage(data: imageData) {
            videoView.isHidden = true
            imageView.isHidden = false
            imageView.image = image
        } else if let videoData = videoData {
            videoView.isHidden = false
            imageView.isHidden = true
            let video = AVMovie(data: videoData, options: .none)
            playerItem = AVPlayerItem(asset: video)
            avPlayer = AVQueuePlayer(playerItem: playerItem)
            
            //        avQueuePlayer = AVQueuePlayer(playerItem: playerItem)
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = videoView.bounds
            avPlayerLayer.videoGravity = .resizeAspectFill
            
            videoView.layer.addSublayer(avPlayerLayer)
            avPlayer.actionAtItemEnd = .pause
            avPlayer.play()
        }
        
        title = post?.title
        
        
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Choose which style of comment you'd like to add", preferredStyle: .actionSheet)
                
        let addTextCommentAction = UIAlertAction(title: "Text Comment", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddTextCommentSegue", sender: self)
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Audio Comment", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddAudioCommentSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addTextCommentAction)
        alert.addAction(addAudioCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        if comment?.audioURL != nil {
            loadAudio(for: cell, forItemAt: indexPath)
            cell.titleLabel.isHidden = true
            cell.playButton.isHidden = false
        } else {
            cell.titleLabel.text = comment?.text
            cell.playButton.isHidden = true
        }
        
        
        cell.authorLabel.text = comment?.author.displayName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let comment = post.comments[indexPath.row]
        
        if let commentID = comment.audioURL {
            operations[commentID]?.cancel()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return }
        
        guard let audioData = cell.audioData else { return }

        do {
            try prepareAudioSession()
        } catch {
            print("Error preparing audio session")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.play()
        } catch {
            print("Error preparing audio session: \(error)")
            return
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddTextCommentSegue" {
            if let addTextCommentVC = segue.destination as? AddTextCommentViewController {
                addTextCommentVC.delegate = self
            }
        } else if segue.identifier == "AddAudioCommentSegue" {
            if let addAudioCommentVC = segue.destination as? AddAudioCommentViewController {
                addAudioCommentVC.delegate = self
            }
        }
    }
    
    func loadAudio(for postCommentCell: CommentTableViewCell, forItemAt indexPath: IndexPath) {
        let comment = post.comments[indexPath.row]
        
        guard let commentID = comment.audioURL else { return }
        
        if let audioData = cache.value(for: commentID) {
            postCommentCell.audioData = audioData
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        let fetchOp = FetchAudioOperation(comment: comment, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.cache.cache(value: data, for: commentID)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }

        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: commentID) }

            if let currentIndexPath = self.tableView.indexPath(for: postCommentCell),
                currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                postCommentCell.audioData = data
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[commentID] = fetchOp
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var videoData: Data?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
            updateViews()
        }
    }
 
    
    private var operations = [String : Operation]()
    private let audioFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
    
    private lazy var avPlayer = AVQueuePlayer()
    private lazy var avPlayerLayer = AVPlayerLayer()
    private var playerItem: AVPlayerItem?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}

extension MediaPostDetailTableViewController: AddTextCommentDelegate {
    func addTextComment(text: String) {
        postController.addTextComment(with: text, to: &post!)
        tableView.reloadData()
    }
}

extension MediaPostDetailTableViewController: AddAudioCommentDelegate {
    func addAudioComment(audioURL: URL) {
        postController.addAudioComment(audioURL: audioURL, oftype: .audio, to: post!) { (error) in
            if let error = error {
                print("Error saving audio to firebase storage: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let fileManager = FileManager()
                
                // To save space in local stprage, delete the file at the orignal location after storing to firebase
                do {
                    print(audioURL)
                    try fileManager.removeItem(at: audioURL)
                } catch {
                    print("Error removing item at URL: \(audioURL)")
                }
            }
        }
    }
}

extension MediaPostDetailTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        tableView.reloadData()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error decoding audio: \(error)")
        }
    }
}
