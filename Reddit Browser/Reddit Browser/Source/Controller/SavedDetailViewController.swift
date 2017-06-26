//
//  SavedDetailViewController.swift
//  Reddit Browser
//
//  Created by Andy Li on 3/14/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//

import CoreData
import UIKit


class SavedDetailViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBAction func sharePost(_ sender: Any) {
        showShareSheet(shareContent: selectedHistory.permalink!)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedDetailCell", for: indexPath) as! SavedDetailCell
        
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
        savedTableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedTextView.text = "\(selectedHistory.title!) \nby: \(selectedHistory.author!)\n\(selectedHistory.permalink!)"
        
        if selectedHistory.textPost == true {
            savedTextView.text = "\(selectedHistory.title!) \nby: \(selectedHistory.author!)\n\(selectedHistory.permalink!)\n\(selectedHistory.textContent!)"
        }
        
        fetchedResultsController = RedditService.shared.commentsForSaved(for: selectedHistory)
        savedNavBar.title = "/r/\(selectedHistory.subreddit!)"
        
        self.savedTableView.estimatedRowHeight = 44
        self.savedTableView.rowHeight = UITableViewAutomaticDimension
        
        if let imageLink = selectedHistory.imageContent{
            let url = URL(string: imageLink)
            guard let data = try? Data(contentsOf: url!) else {
                return
            }
            savedImageView.image = UIImage(data: data)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let contentSize = self.savedTextView.sizeThatFits(self.savedTextView.bounds.size)
        var frame = self.savedTextView.frame
        frame.size.height = contentSize.height
        self.savedTextView.frame = frame
        
        aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.savedTextView, attribute: .height, relatedBy: .equal, toItem: self.savedTextView, attribute: .width, multiplier: savedTextView.bounds.height/savedTextView.bounds.width, constant: 1)
        self.savedTextView.addConstraint(aspectRatioTextViewConstraint!)
    }
    
    
    // MARK: Properties
    // This property is set by the FruitsViewController to the name of the fruit that the user selected during the segue
    // that presents this view controller.  It is used to show the values that correspond to the user's selection.
    var selectedHistory: History! = nil
    
    // MARK: Properties (Private)
    var fetchedResultsController: NSFetchedResultsController<Comments>!
    
    // MARK: Properties (IBOutlet)
    
    @IBOutlet weak var aspectRatioTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var savedNavBar: UINavigationItem!
    @IBOutlet weak var savedTextView: UITextView!
    @IBOutlet weak var savedImageView: UIImageView!
    @IBOutlet weak var savedTableView: UITableView!

}
