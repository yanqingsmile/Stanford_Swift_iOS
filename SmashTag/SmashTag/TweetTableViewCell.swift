//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/14/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            var labelText = tweet.text
            
            for _ in tweet.media {
                labelText += " 📷"
            }
            // convert to attributed string
            
            let attributedString = NSMutableAttributedString(string: labelText)
            let hashTagAttributes = [NSForegroundColorAttributeName: UIColor.red]
            let urlAttributes = [NSForegroundColorAttributeName: UIColor.blue]
            let userMentionAttributes = [NSForegroundColorAttributeName: UIColor.brown]
            
            for hashtag in tweet.hashtags {
                attributedString.addAttributes(hashTagAttributes, range: hashtag.nsrange)
            }
            for url in tweet.urls {
                attributedString.addAttributes(urlAttributes, range: url.nsrange)
            }
            for userMention in tweet.userMentions {
                attributedString.addAttributes(userMentionAttributes, range: userMention.nsrange)
            }
            

            tweetTextLabel?.attributedText = attributedString
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                DispatchQueue.global(qos: .default).async {[weak weakSelf = self] in
                    if let imageData = NSData(contentsOf: profileImageURL) {
                        DispatchQueue.main.async {
                            weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if NSDate().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }
        
    }

}

