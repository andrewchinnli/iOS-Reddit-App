//
//  TopViewController.swift
//  Reddit Browser
//
//  Created by Andy Li on 3/12/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//

import CoreData
import UIKit

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
NSFetchedResultsControllerDelegate {
    
    @IBAction private func Refresh(sender: AnyObject) {
        RedditService.shared.topRefreshData()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // In the case that we encounter a nil value, we provide a default value of 0
        return postsFetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // In the case that we encounter a nil value, we provide a default value of 0
        return postsFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ask the table view for a cell and configure it with the object that the fetched results controller returns
        // for the indexPath.  Make sure to use the version of the dequeueReusableCell method that accepts the indexPath
        // parameter.  The other version will not work in the same way.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopCell", for: indexPath) as! TopCell
        
        let post = postsFetchedResultsController.object(at: indexPath)
        
        cell.title?.text = post.title
        cell.subtitle?.text = "/r/\(post.subreddit!)"
        cell.score?.text = "\(String(post.score)) Points"
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This implementation is trivial, so it would be equivalent to setup the segue directly in the storyboard.  You
        // should not do both, as this will cause a double segue and potentially a crash depending on how your prepare
        // for segue method is implemented.
        performSegue(withIdentifier: "TopDetailSegue", sender: self)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // There are additional methods in this delegate protocol that can be used for more detailed updates, for this
        // simple app we can just reload the entire table for any content change.
        topTableView.reloadData()
    }
    
    // MARK: View Management
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TopDetailSegue" {
            // Configure the destination view controller with information about what was selected so it can show
            // appropriate details.
            let TopDetailViewController = segue.destination as! TopDetailViewController
            let indexPath = topTableView.indexPathForSelectedRow!
            topTableView.selectRow(at: nil, animated: true, scrollPosition: .none)
            TopDetailViewController.selectedPost = postsFetchedResultsController?.object(at: indexPath)
        }
        else {
            // If the segue has an identifier that is unknown to this view controller, pass it to super.
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retrieve the fetched results controller from the top service to prevent unnecessary creation of multiple
        // fetches
        postsFetchedResultsController = RedditService.shared.topPosts()
        
        self.topTableView.estimatedRowHeight = 44
        self.topTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set the delegate to self so that we can respond to updates in the data
        postsFetchedResultsController.delegate = self
    }
    
    // MARK: Properties (Private)
    // We use an implicitly unwrapped optional type because the value is not set until the view loads
    private var postsFetchedResultsController: NSFetchedResultsController<Posts>!
    
    // MARK: Properties (IBOutlet)
    @IBOutlet weak var topTableView: UITableView!
}





