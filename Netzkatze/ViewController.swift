//
//  ViewController.swift
//  Netzkatze
//
//  Created by silsha on 12/11/14.
//  Copyright (c) 2014 silsha. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric


class ViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, TWTRTweetViewDelegate {
    
    
    @IBOutlet weak var naivationbar: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sending: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // setup a 'container' for Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var prototypeCell: TWTRTweetTableViewCell?
    let tweetTableCellReuseIdentifier = "TweetCell"
    var isLoadingTweets = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) {
            self.sending.text = "";
        }
        textView.text = "Maunz. Wie geht’s dir?"
        textView.textColor = UIColor.lightGrayColor()
        
        textView.becomeFirstResponder()
        textView.delegate = self;
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        
        // Create a single prototype cell for height calculations.
        self.prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: tweetTableCellReuseIdentifier)
        
        // Register the identifier for TWTRTweetTableViewCell.
        self.tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)
        // Setup table data
        
        loadTweets()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make sure the navigation bar is not translucent when scrolling the table view.
        self.navigationController?.navigationBar.translucent = false
    }
    
    
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if countElements(updatedText) == 0 {
            
            textView.text = "Maunz. Wie geht’s dir?"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView!) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    class CustomObject {
        var id: Int = 0
        
        init(json: Dictionary<String, AnyObject>) {
            id = (json["id"] as NSNumber).integerValue
        }
    }
    
    func loadTweets() {
        // Do not trigger another request if one is already in progress.
        if self.isLoadingTweets {
            return
        }
        self.isLoadingTweets = true
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["user_id": "899670319"]
        var clientError : NSError?
        
        Twitter.sharedInstance().logInGuestWithCompletion {
            (guestSession, error) -> Void in
            if (guestSession != nil) {
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
                "GET", URL: statusesShowEndpoint, parameters: params,
                error: &clientError)
                
            
        
        if request != nil {

                    Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                        (response, data, connectionError) -> Void in
                        if (connectionError == nil) {
                            var jsonError : NSError?
                            var json      = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as Array<Dictionary<String, AnyObject>>
                            var customObjects = json.map { dict in CustomObject(json: dict) }
                            var tweetids : [String] = []
                            for i in customObjects {
                                tweetids.append(String(i.id));
                            }
                            Twitter.sharedInstance().APIClient
                                .loadTweetsWithIDs(tweetids) {
                                    (tweets, error) -> Void in
                                    self.tweets = [];
                                    for i in tweets {
                                        self.tweets.append(i as TWTRTweet)
                                    }
                            }
                        
                        }
                        else {
                            println("Error: \(connectionError)")
                        }
                    
            
            }}
    
        else {
            println("Error: \(clientError)")
        }
        
            }}}
    
    


//            (tweetIDs) {
//                (twttrs, error) -> Void in
//
//                // If there are tweets do something magical
//                if ((twttrs) != nil) {
//
//                    // Loop through tweets and do something
//                    for i in twttrs {
//                        // Append the Tweet to the Tweets to display in the table view.
//                        self.tweets.append(i as TWTRTweet)
//                    }
//                } else {
//                    println(error)
//                }
    
    func refreshInvoked() {
        // Trigger a load for the most recent Tweets.
        loadTweets()
    }
    
    // MARK: TWTRTweetViewDelegate
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        // Display a Web View when selecting the Tweet.
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(NSURLRequest(URL: tweet.permalink))
        webViewController.view = webView
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of Tweets.
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableCellReuseIdentifier, forIndexPath: indexPath) as TWTRTweetTableViewCell
        
        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        // Configure the cell with the Tweet.
        cell.configureWithTweet(tweet)
        
        // Return the Tweet cell.
        return cell
    }
    

    
    


    @IBAction func sendTweet(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.sending.text = "Maaunz …";
        }
        let url : String = "https://netzkatze.ohai.su/~lutoma/cgi-bin/netzkatze-jsonsubmit.py";
        var request : NSMutableURLRequest = NSMutableURLRequest();
        request.URL = NSURL(string: url);
        request.HTTPMethod = "POST";
        request.HTTPBody = ("{\"tweet\":\"\(textView.text)\"}" as NSString).dataUsingEncoding(NSUTF8StringEncoding);
        
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            dispatch_async(dispatch_get_main_queue()) {
                self.textView.text = "";
                self.sending.text = "";
                self.isLoadingTweets = false;
                let delay = 1.5 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.refreshInvoked();
                }
            }
            
            
        })
        
    }

}

