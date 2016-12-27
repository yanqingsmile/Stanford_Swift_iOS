//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/11/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var searchedTexts = UserDefaults.standard.object(forKey: ConstantString.userDefaultsKey) as? [String?] ?? [String?]()
    
    var searchText : String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            navigationItem.title = searchText
            
            if searchedTexts.count >= 6 {
                searchedTexts.remove(at: searchedTexts.count - 1)
            }
            searchedTexts.insert(searchText, at: 0)
            UserDefaults.standard.set(searchedTexts, forKey: ConstantString.userDefaultsKey)
        }
    }
    
    private var twitterRequest: Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query + "-filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets({ [weak weakSelf = self](newTweets) in
                DispatchQueue.main.async {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                        }
                    }
                }
            })
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if searchText == nil {
            searchText = ConstantString.defaultSearchText
            searchedTexts.remove(at: 0)
            UserDefaults.standard.set(searchedTexts, forKey: ConstantString.userDefaultsKey)
        }
    }

    
    // MARK: - UITableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    private struct StoryBoard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    private struct ConstantString {
        static let defaultSearchText = "#stanford"
        static let userDefaultsKey = "searchedTexts"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.TweetCellIdentifier, for: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let tweetDetailViewController = segue.destination as! DetailTableViewController
        if let selectedTweetCell = sender as? TweetTableViewCell {
            let indexPath = tableView.indexPath(for: selectedTweetCell)
            let selectedTweet = tweets[(indexPath?.section)!][(indexPath?.row)!]
            tweetDetailViewController.tweet = selectedTweet
        }
        
        // Pass the selected object to the new view controller.
    }
    

}
