//
//  NextViewController.swift
//  firebase2
//
//  Created by KS on 2021/05/23.
//

import UIKit
import Firebase
//import FirebaseFirestore


class NextViewController: UIViewController,
                          UITableViewDataSource,
                          UITableViewDelegate{
    
    
    
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    var docID = String()
    var titleString = String()
    var chat:[ChatData] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        label.text = titleString
        loadComment()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label = cell.contentView.viewWithTag(1) as! UILabel
        
        label.text = chat[indexPath.row].comment
        
        return cell
    }
    
    
    
    @IBAction func send(_ sender: Any) {
        
        if textField.text?.isEmpty == true{
            return
        }
        
        db.collection("comments").document(docID).collection("chat").document().setData(["comment":textField.text as Any,"postDate":Date().timeIntervalSince1970])
        
        loadComment()
        
        textField.text = ""
        textField.resignFirstResponder()
        
    }
    
    func loadComment(){
        
        db.collection("comments").document(docID).collection("chat").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            
            self.chat = []
            
            if error != nil{
               print("error")
            }
            
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc{
                    
                    let data = doc.data()
                    if let comment = data["comment"] as? String,let postDate = data["postDate"] as? Double{
                        
                        
                        let chatData = ChatData(comment: comment, postDate: postDate)
                        self.chat.append(chatData)
                    }
                }
                
                self.chat.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    
}
