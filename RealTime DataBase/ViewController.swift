//
//  ViewController.swift
//  RealTime DataBase
//
//  Created by JAYDEN SAWYER on 2/6/25.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {
  @IBOutlet weak var textoutlet: UITextField!
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    @IBAction func buttonaction(_ sender: Any) {
        var name = textoutlet.text!
        ref.child("students").childByAutoId().setValue(name)

    }
    
}

