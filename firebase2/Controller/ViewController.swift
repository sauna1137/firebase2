//
//  ViewController.swift
//  firebase2
//
//  Created by KS on 2021/05/22.
//

import UIKit
import Firebase
import FirebaseFirestore


class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    
    let db = Firestore.firestore()
    var commentsData:[CommentsData] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadComment()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label = cell.contentView.viewWithTag(1) as! UILabel
        
        label.text = commentsData[indexPath.row].comments
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "nextVC") as! NextViewController
        
        nextVC.docID = commentsData[indexPath.row].docID
        nextVC.titleString = commentsData[indexPath.row].comments
        
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        
    }
    
   
    
    
    
    
    @IBAction func commentButton(_ sender: Any) {
        
        if textField.text?.isEmpty == true{
            return
        }
        
        db.collection("comments").document().setData(["comment":textField.text as Any,"postDate":Date().timeIntervalSince1970])
        
        loadComment()
        
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    
    func loadComment(){
    
        
        
        db.collection("comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            
            self.commentsData = []
            
            if error != nil{
                return
                    print(error.debugDescription)
            }
            
            
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc {
                    let data = doc.data()
                    
                    if let comments = data["comment"] as? String, let postDate = data["postDate"] as? Double{
                        
                        let newData = CommentsData(comments: comments,postDate: postDate, docID: doc.documentID)
                        
                        
                        self.commentsData.append(newData)
                    }
                }
                
                self.commentsData.reverse()
                
                self.tableView.reloadData()
            }
        }
    }
}


