//
//  SavedViewController.swift
//  Reddit Browser
//
//  Created by Andy Li on 3/12/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//
import CoreData
import UIKit

class SavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
NSFetchedResultsControllerDelegate {

    @IBAction func deleteHistory(_ sender: Any) {
        RedditService.shared.deleteSaved()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCell", for: indexPath) as! SavedCell
        
        let history = postsFetchedResultsController.object(at: indexPath)
        
        cell.title?.text = history.title
        guard let subreddit = history.subreddit else{
            return cell
        }
        cell.subtitle?.text = "/r/\(subreddit)"
        cell.score?.text = "\(String(history.score)) Points"
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This implementation is trivial, so it would be equivalent to setup the segue directly in the storyboard.  You
        // should not do both, as this will cause a double segue and potentially a crash depending on how your prepare
        // for segue method is implemented.
        performSegue(withIdentifier: "SavedDetailSegue", sender: self)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // There are additional methods in this delegate protocol that can be used for more detailed updates, for this
        // simple app we can just reload the entire table for any content change.
        savedTableView.reloadData()
    }
    
    // MARK: View Management
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SavedDetailSegue" {
            // Configure the destination view controller with information about what was selected so it can show
            // appropriate details.
            let SavedDetailViewController = segue.destination as! SavedDetailViewController
            let indexPath = savedTableView.indexPathForSelectedRow!
            savedTableView.selectRow(at: nil, animated: true, scrollPosition: .none)
            SavedDetailViewController.selectedHistory = postsFetchedResultsController?.object(at: indexPath)
        }
        else {
            // If the segue has an identifier that is unknown to this view controller, pass it to super.
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retrieve the fetched results controller from the hot service to prevent unnecessary creation of multiple
        // fetches
        
        postsFetchedResultsController = RedditService.shared.savedPosts()
        
        self.savedTableView.estimatedRowHeight = 44
        self.savedTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set the delegate to self so that we can respond to updates in the data
        postsFetchedResultsController.delegate = self
    }
    
    // MARK: Properties (Private)
    // We use an implicitly unwrapped optional type because the value is not set until the view loads
    private var postsFetchedResultsController: NSFetchedResultsController<History>!
    
    // MARK: Properties (IBOutlet)
    
    @IBOutlet weak var savedTableView: UITableView!
}



