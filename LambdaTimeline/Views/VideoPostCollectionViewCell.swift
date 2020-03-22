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
    
    
    private lazy var avQueuePlayer = AVQueuePlayer()
    private lazy var avPlayerLayer = AVPlayerLayer()
    private var playerItem: AVPlayerItem?
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    
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
        
        avQueuePlayer = AVQueuePlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avQueuePlayer)
        avPlayerLayer.frame = videoPostPlayerView.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        
        videoPostPlayerView.layer.addSublayer(avPlayerLayer)
        avQueuePlayer.play()
    }

    
}

