//
//  ViewController.swift
//  Netzkatze
//
//  Created by silsha on 12/11/14.
//  Copyright (c) 2014 silsha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var naivationbar: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sending: UILabel!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) {
            self.sending.text = "";
        }
        textView.text = "Maunz. Wie geht’s dir?"
        textView.textColor = UIColor.lightGrayColor()
        
        textView.becomeFirstResponder()
        textView!.delegate = self
        
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
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
            }
            
            
        })
        
    }

}

