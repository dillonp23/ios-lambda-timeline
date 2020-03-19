//
//  AddTextCommentViewController.swift
//  LambdaTimeline
//
//  Created by Dillon P on 3/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AddTextCommentViewController: UIViewController {
    
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: AddTextCommentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveButtonTapped() {
        guard let comment = commentTextField.text else { return }
        delegate?.addTextComment(text: comment)
        self.dismiss(animated: true, completion: nil)
    }

    

}
