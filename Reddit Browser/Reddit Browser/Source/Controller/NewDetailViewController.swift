//
//  NewDetailViewController.swift
//  Reddit Browser
//
//  Created by Andy Li on 3/14/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//

import CoreData
import UIKit


class NewDetailViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBAction func savePost(_ sender: Any) {
        RedditService.shared.savePost(post: selectedPost)
    }

    @IBAction func sharePost(_ sender: Any) {
        showShareSheet(shareContent: selectedPost.permalink!)
    }
    
    func showShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // When using a custom cell type, it is necessary to cast the result of the dequeueReusableCell method call
        // to the type set in the Storyboard.
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewDetailCell", for: indexPath) as! NewDetailCell
        
        let commentObject = fetchedResultsController.object(at: indexPath)
        
        do {
            guard let content = commentObject.content else {
                return cell
            }
            guard let author = commentObject.author else {
                return cell
            }
            
            cell.title?.text = content
            cell.subtitle?.text = author
            if (commentObject.score == 1) {
                cell.score?.text = "\(String(commentObject.score)) Point"
            } else {
                cell.score?.text = "\(String(commentObject.score)) Points"
            }
        }
        
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        newTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTextView.text = "\(selectedPost.title!) \nby: \(selectedPost.author!)\n\(selectedPost.permalink!)"
        
        if selectedPost.textPost == true {
            newTextView.text = "\(selectedPost.title!) \nby: \(selectedPost.author!)\n\(selectedPost.permalink!)\n\(selectedPost.textContent!)"
        }
        
        fetchedResultsController = RedditService.shared.comments(for: selectedPost)
        newNavBar.title = "/r/\(selectedPost.subreddit!)"
        
        self.newTableView.estimatedRowHeight = 44
        self.newTableView.rowHeight = UITableViewAutomaticDimension
        
        if let imageLink = selectedPost.imageContent{
            let url = URL(string: imageLink)
            guard let data = try? Data(contentsOf: url!) else {
                return
            }
            newImageView.image = UIImage(data: data)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let contentSize = self.newTextView.sizeThatFits(self.newTextView.bounds.size)
        var frame = self.newTextView.frame
        frame.size.height = contentSize.height
        self.newTextView.frame = frame
        
        aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.newTextView, attribute: .height, relatedBy: .equal, toItem: self.newTextView, attribute: .width, multiplier: newTextView.bounds.height/newTextView.bounds.width, constant: 1)
        self.newTextView.addConstraint(aspectRatioTextViewConstraint!)
    }
    
    // MARK: Properties
    // This property is set by the FruitsViewController to the name of the fruit that the user selected during the segue
    // that presents this view controller.  It is used to show the values that correspond to the user's selection.
    var selectedPost: Posts! = nil
    
    // MARK: Properties (Private)
    var fetchedResultsController: NSFetchedResultsController<Comments>!
    
    // MARK: Properties (IBOutlet)
    
    @IBOutlet weak var aspectRatioTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTableView: UITableView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var newNavBar: UINavigationItem!
    @IBOutlet weak var newTextView: UITextView!

}
