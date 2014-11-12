//
//  ViewController.swift
//  Netzkatze
//
//  Created by silsha on 12/11/14.
//  Copyright (c) 2014 silsha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var naivationbar: UINavigationItem!
    @IBOutlet weak var input: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendTweet(sender: UIButton) {
        let url : String = "https://netzkatze.ohai.su/~lutoma/cgi-bin/netzkatze-jsonsubmit.py";
        var request : NSMutableURLRequest = NSMutableURLRequest();
        request.URL = NSURL(string: url);
        request.HTTPMethod = "POST";
        request.HTTPBody = ("{\"tweet\":\"\(input.text)\"}" as NSString).dataUsingEncoding(NSUTF8StringEncoding);
        
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            dispatch_async(dispatch_get_main_queue()) {
                self.input.text = "";
            }
            
            
        })
        
    }

}

