//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoPostPlayerView: UIView!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    private lazy var avPlayer = AVQueuePlayer()
    private lazy var avPlayerLayer = AVPlayerLayer()
    private var playerItem: AVPlayerItem?
    
    var mediaData: Data?
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    var didPlay: Bool = false
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        authorLabel.text = ""
    }
    func setupLabelBackgroundView() {
           labelBackgroundView.layer.cornerRadius = 8
           //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
           //        labelBackgroundView.layer.borderWidth = 0.5
           labelBackgroundView.clipsToBounds = true
       }
    
    func updateViews() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    func setupVideoPlayer(with data: Data) {

        let video = AVMovie(data: data, options: .none)
        playerItem = AVPlayerItem(asset: video)
        avPlayer = AVQueuePlayer(playerItem: playerItem)

//        avQueuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = contentView.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill

        videoPostPlayerView.layer.addSublayer(avPlayerLayer)
        avPlayer.isMuted = true
        avPlayer.actionAtItemEnd = .pause
        avPlayer.play()
//        didPlay = true
    }
    
//    func replayVideo() {
//        avPlayer = AVQueuePlayer(playerItem: playerItem)
//        avPlayerLayer = AVPlayerLayer(player: avPlayer)
//        avPlayer.play()
//    }
    

    
}

