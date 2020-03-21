//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    init(comment: Comment, postController: PostController, session: URLSession = URLSession.shared) {
        self.comment = comment
        self.postController = postController
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        
        guard let urlString = comment.audioURL,
            let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.comment): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch audio operation data task.")
                return
            }
            self.audioData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let comment: Comment
    let postController: PostController
    var audioData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
}
