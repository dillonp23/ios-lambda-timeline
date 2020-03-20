//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol AddTextCommentDelegate {
     func addTextComment(text: String)
 }

protocol AddAudioCommentDelegate {
    func addAudiComment(audioURL: URL)
}

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
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
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell2", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        if comment?.text != nil {
            cell.titleLabel.text = comment?.text
            cell.authorLabel.text = comment?.author.displayName
            cell.playButton.isHidden = true
        } else {
            // TODO: configure cell for audio
//                cell.titleLabel.isHidden = true
//                cell.playButton.isHidden = false
        }
        
        return cell
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
    
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}

extension ImagePostDetailTableViewController: AddTextCommentDelegate {
    func addTextComment(text: String) {
        postController.addComment(with: text, to: &post!)
        tableView.reloadData()
    }
}

extension ImagePostDetailTableViewController: AddAudioCommentDelegate {
    func addAudiComment(audioURL: URL) {
        tableView.reloadData()
    }
    
}
