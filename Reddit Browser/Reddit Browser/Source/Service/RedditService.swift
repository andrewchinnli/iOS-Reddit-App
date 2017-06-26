//
//  RedditService.swift
//  Reddit Browser
//
//  Created by Andy Li on 3/12/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//

import CoreData
import Foundation

class RedditService {
    // MARK: Data Access
    func hotRefreshData() {
        
        ////////////////////////////////////
        // Construct a URL and URLRequest //
        // for hot posts                  //
        ////////////////////////////////////
        let hotURL = URL(string: RedditService.hotDataURL)!
        let hotURLRequest = URLRequest(url: hotURL)
        
        // Create a data task for the hotURLRequest
        let hotDataTask = session.dataTask(with: hotURLRequest) { (data, response, error) in
            guard error == nil else {
                print("Error refreshing data \(error!)")
                return
            }
            guard let someResponse = response as? HTTPURLResponse, someResponse.statusCode >= 200, someResponse.statusCode < 300  else {
                print("Invalid response or non-200 status code")
                return
            }
            guard let someData = data else {
                return
            }
            guard let postValues = (try? JSONSerialization.jsonObject(with: someData, options: [.allowFragments])) as? Dictionary<String, Any> else {
                return
            }
            let postInfo = postValues["data"]
            self.processData(postData: postInfo as! Dictionary<String, Any>, type: "hot")
        }
        hotDataTask.resume()
    }
    
    func topRefreshData() {
        ////////////////////////////////////
        // Construct a URL and URLRequest //
        // for top posts                  //
        ////////////////////////////////////
        let topURL = URL(string: RedditService.topDataURL)!
        let topURLRequest = URLRequest(url: topURL)
        
        // Create a data task for the hotURLRequest
        let topDataTask = session.dataTask(with: topURLRequest) { (data, response, error) in
            guard error == nil else {
                print("Error refreshing data \(error!)")
                return
            }
            guard let someResponse = response as? HTTPURLResponse, someResponse.statusCode >= 200, someResponse.statusCode < 300  else {
                print("Invalid response or non-200 status code")
                return
            }
            guard let someData = data else {
                return
            }
            guard let postValues = (try? JSONSerialization.jsonObject(with: someData, options: [.allowFragments])) as? Dictionary<String, Any> else {
                return
            }
            let postInfo = postValues["data"]
            self.processData(postData: postInfo as! Dictionary<String, Any>, type: "top")
        }
        topDataTask.resume()
    }
    
    func newRefreshData() {
        ////////////////////////////////////
        // Construct a URL and URLRequest //
        // for new posts                  //
        ////////////////////////////////////
        let newURL = URL(string: RedditService.newDataURL)!
        let newURLRequest = URLRequest(url: newURL)
        
        // Create a data task for the hotURLRequest
        let newDataTask = session.dataTask(with: newURLRequest) { (data, response, error) in
            guard error == nil else {
                print("Error refreshing data \(error!)")
                return
            }
            guard let someResponse = response as? HTTPURLResponse, someResponse.statusCode >= 200, someResponse.statusCode < 300  else {
                print("Invalid response or non-200 status code")
                return
            }
            guard let someData = data else {
                return
            }
            guard let postValues = (try? JSONSerialization.jsonObject(with: someData, options: [.allowFragments])) as? Dictionary<String, Any> else {
                return
            }
            let postInfo = postValues["data"]
            self.processData(postData: postInfo as! Dictionary<String, Any>, type: "new")
        }
        newDataTask.resume()
    }
    
    private func processData(postData: Dictionary<String, Any>, type: String) {
        let context = persistentContainer.viewContext
        
        // Use the perform method to ensure correct CoreData access
        context.perform {
            // Fetch all existing post objects so they can be updated if they exist already and deleted if they are no
            // longer in the postData.  The results are usually returned in an Array, but they are converted to a Set
            // here for convenience.
            
            let fetchRequest: NSFetchRequest<Posts> = Posts.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "type == %@", type)
            var allPosts = Set((try? context.fetch(fetchRequest)) ?? [])
            
            // Iterate through all the postValues returned from the web service and update or create CoreData as
            // appropriate
            let postList = postData["children"] as! [Dictionary<String,Any>]
            
            for postValues in postList {
                // The name value will be used as a unique identifier for the post objects.  Often data models have an
                // id attribute, which is ideally what would be used to identify an object uniquely.
                let postUnwrap = postValues["data"] as! Dictionary<String,Any>
                
                let title = (postUnwrap["title"] as! String).replacingOccurrences(of: "&amp;", with: "&")
                let score = postUnwrap["score"] as! Int32
                let subreddit = postUnwrap["subreddit"] as! String
                let permalink = "https://www.reddit.com\(postUnwrap["permalink"]!)"
                
                let textContent = postUnwrap["selftext"] as! String
                let thumbnail = postUnwrap["thumbnail"] as! String
                let imageContent = postUnwrap["url"] as! String
                var newImageContent = imageContent.replacingOccurrences(of: "&amp;", with: "&")
                if newImageContent.range(of:"imgur.com") != nil{
                    newImageContent.append(".jpg")
                }
                    
                let author = postUnwrap["author"] as! String
                
                
                // Look for an existing post with the same name to update or create a new Post if nothing is found
                let existingPost = allPosts.first(where: { $0.title == title && $0.type == type})
                let posts: Posts
                if let someExistingPost = existingPost {
                    posts = someExistingPost
                    
                    allPosts.remove(someExistingPost)
                }
                else {
                    posts = Posts(context: context)
                }
                
                // Set the attributes and relationships based on the data values
                posts.score = score
                posts.title = title
                posts.subreddit = subreddit
                posts.type = type
                posts.permalink = permalink
                posts.author = author
                

                posts.textContent = textContent
                posts.imageContent = newImageContent
                
                if thumbnail == "self" {
                    posts.textPost = true
                } else {
                    posts.textPost = false
                }
                
//                /////////////////////////
//                // COMMENT DATA STREAM //
//                /////////////////////////
//                
                let commentEncoded = "\(permalink.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!).json"
                let commentURL = URL(string: commentEncoded)!
                let commentURLRequest = URLRequest(url: commentURL)

                // Create a data task for the URLRequest
                let commentDataTask = self.session.dataTask(with: commentURLRequest) { (data, response, error) in
                    // All parameters will potentially be nil depending on what occurred during the request.  Applications
                    // should present potential errors to the user as appropriate.
                    
                    // Check to make sure there is no error
                    guard error == nil else {
                        print("Error refreshing data \(error!)")
                        return
                    }
                    
                    guard let someResponse = response as? HTTPURLResponse, someResponse.statusCode >= 200, someResponse.statusCode < 300  else {
                        print("Invalid response or non-200 status code")
                        return
                    }
                    
                    guard let someData = data else {
                        return
                    }
                    
                    guard let commentValues = (try? JSONSerialization.jsonObject(with: someData, options: [.allowFragments])) as? [Any] else {
                        return
                    }
                    
                    let commentInfo = commentValues[1] as! Dictionary<String,Any>
                    let commentsTemp = commentInfo["data"] as! Dictionary<String,Any>
                    let commentsArray = commentsTemp["children"] as! [Dictionary<String,Any>]
                    
                    self.processComments(commentsArray: commentsArray, context: context, posts: posts)
                }
                
                commentDataTask.resume()
                
            }
            
            // Delete anything remaining in allposts, as they were no longer included in the data
            for somePost in allPosts {
                context.delete(somePost)
            }
            
            // Make sure to save the changes made.
            try! context.save()
        }
    }
    
    func processComments(commentsArray: [Dictionary<String,Any>], context: NSManagedObjectContext, posts: Posts) {
        context.perform {
            if let commentValues = posts.postsToComments as? Set<Comments> {
                commentValues.forEach({ context.delete($0) })
            }

            for someCommentValue in commentsArray {
                let comment = Comments(context: context)
                comment.author = (someCommentValue["data"] as? Dictionary<String,Any>)?["author"] as! String?
                comment.content = (someCommentValue["data"] as? Dictionary<String,Any>)?["body"] as! String?
                do {
                    guard let score = (someCommentValue["data"] as? Dictionary<String,Any>)?["score"] as! Int32? else {
                        continue
                    }
                    comment.score = score
                }
            // If the inverse relationship is setup correctly in the data model, you only need to set one
            // side of the relationship.  CoreData will manage the other side for you.
                comment.commentsToPosts = posts
            }
            try! context.save()
        }
    }
    
    func savePost(post: Posts) {
        let context = persistentContainer.viewContext
        context.perform {
            let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
            var allHistory = Set((try? context.fetch(fetchRequest)) ?? [])
            
            let existingHistory = allHistory.first(where: { $0.title == post.title})
            let history: History
            if let someExistingHistory = existingHistory {
                history = someExistingHistory
                
                allHistory.remove(someExistingHistory)
            }
            else {
                history = History(context: context)
            }
            
            history.author = post.author
            history.imageContent = post.imageContent
            history.permalink = post.permalink
            history.score = post.score
            history.subreddit = post.subreddit
            history.textContent = post.textContent
            history.textPost = post.textPost
            history.title = post.title
        
            if let commentValues = post.postsToComments as? Set<Comments> {
                for comment in commentValues{
                    comment.commentsToHistory = history
                }
            }
            history.time = Date() as NSDate
        
            try! context.save()
        }
    }
    
    func deleteSaved() {
        let context = persistentContainer.viewContext
        context.perform {
            let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
            let allHistory = Set((try? context.fetch(fetchRequest)) ?? [])
            
            for someHistory in allHistory {
                context.delete(someHistory)
            }
            
            try! context.save()
        }
    }
    
    func hotPosts() -> NSFetchedResultsController<Posts> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all Post objects sorted by name from
        // A - Z.".
        
        // Create an NSFetchRequest for Post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<Posts> = Posts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", "hot")
        
        // Setup the fetch request to sort by name.  Fetch requests to be used in fetched results controllers must sort
        // by something.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    func topPosts() -> NSFetchedResultsController<Posts> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all Post objects sorted by name from
        // A - Z.".
        
        // Create an NSFetchRequest for Post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<Posts> = Posts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", "top")
        
        // Setup the fetch request to sort by name.  Fetch requests to be used in fetched results controllers must sort
        // by something.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    func newPosts() -> NSFetchedResultsController<Posts> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all Post objects sorted by name from
        // A - Z.".
        
        // Create an NSFetchRequest for Post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<Posts> = Posts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", "new")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    func savedPosts() -> NSFetchedResultsController<History> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all Post objects sorted by name from
        // A - Z.".
        
        // Create an NSFetchRequest for Post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        // Setup the fetch request to sort by name.  Fetch requests to be used in fetched results controllers must sort
        // by something.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    
    
    func comments(for posts: Posts) -> NSFetchedResultsController<Comments> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all comments objects for post sorted by
        // their orderIndex value starting at zero.".
        
        // Create an NSFetchRequest for post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<Comments> = Comments.fetchRequest()
        
        // For this fetch request we only want to retrieve the Comment objects whose post relationship is equal to the
        // post parameter.  We must use a predicate for this.  If we omit this predicate we get all comments objects.
        fetchRequest.predicate = NSPredicate(format: "commentsToPosts == %@", posts)
        
        // Setup the fetch request to sort by the orderIndex value.  Fetch requests to be used in fetched results
        // controllers must sort by something.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    func commentsForSaved(for history: History) -> NSFetchedResultsController<Comments> {
        // The English sentence that describes this NSFetchRequest is "Retrieve all comments objects for post sorted by
        // their orderIndex value starting at zero.".
        
        // Create an NSFetchRequest for post objects.  We cannot use type inference here, because there are multiple
        // methods of the same name that return different types.  If we omit the type, there will be a compiler error
        // about ambiguous usage.
        let fetchRequest: NSFetchRequest<Comments> = Comments.fetchRequest()
        
        // For this fetch request we only want to retrieve the Comment objects whose post relationship is equal to the
        // post parameter.  We must use a predicate for this.  If we omit this predicate we get all comments objects.
        fetchRequest.predicate = NSPredicate(format: "commentsToHistory == %@", history)
        
        // Setup the fetch request to sort by the orderIndex value.  Fetch requests to be used in fetched results
        // controllers must sort by something.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        return fetchedResultsController(for: fetchRequest)
    }
    
    // MARK: Private
    func fetchedResultsController<T>(for fetchRequest: NSFetchRequest<T>) -> NSFetchedResultsController<T> {
        // This method just creates a fetched results controller for a fetch request, converting the error into a fatal
        // error.  Since this is common code it is good practice to place it in a method rather than copy/pasting it.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        }
        catch let error {
            fatalError("Could not perform fetch for fetched results controller: \(error)")
        }
        
        return fetchedResultsController
    }

    // MARK: Initialization
    // This init method is marked as private so that nothing can instantiate postService directly.  Instead using the
    // shared static property to access a shared "singleton" instance.
    private init() {
        // Create the NSPersistentContainer.  If you wish to use the default configuration (which is sufficient for this
        // app and assignment 5), you only need to pass a name here that matches the data model file in the project.
        persistentContainer = NSPersistentContainer(name: "Model")
        
        // The loadPersistentStores(completionHandler:) method will load any pre-existing databases for the persistent
        // container, creating them if need be.  This is done asynchronously and the completionHandler closure is
        // executed once it has finished.  The completion handler is where you should put CoreData initialization code.
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.hotRefreshData()
            self.newRefreshData()
            self.topRefreshData()
        })
    }
    
    // MARK: Properties (Private)
    private let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    private let persistentContainer: NSPersistentContainer
    
    // MARK: Properties (Private Static Constant)
    private static let hotDataURL = "https://www.reddit.com/.json"
    private static let topDataURL = "https://www.reddit.com/top/.json?sort=top&t=all"
    private static let newDataURL = "https://www.reddit.com/new/.json"
    
    // MARK: Properties (Static Constant)
    static let shared = RedditService()
}
