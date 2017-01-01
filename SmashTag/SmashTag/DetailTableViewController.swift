//
//  DetailTableViewController.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/18/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class DetailTableViewController: UITableViewController {
    
    
    var tweet: Twitter.Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tweet detail"
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        print(tweet!)
        addBackToRootButton()
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case SectionContent.image.rawValue:
            return (tweet?.media.count)!
        case SectionContent.hashTags.rawValue:
            return (tweet?.hashtags.count)!
        case SectionContent.urls.rawValue:
            return (tweet?.urls.count)!
        case SectionContent.users.rawValue:
            return (tweet?.userMentions.count)! + 1 // plus the user who posted the tweet
        default:
            return 0
        }
    }
    
    private enum SectionContent: Int {
        case image, hashTags, urls, users
    }
    
    private struct StoryBoard {
        static let imageCellIdentifier = "imageTableViewCell"
        static let textCellIdentifier = "textTableViewCell"
        static let searchTweetSegue = "searchTweetSegue"
        static let showImageSegue = "showImage"
    }
    
    private var textCellDictionary: [Int: [Mention]?] {
        get {
            return [
                SectionContent.hashTags.rawValue: tweet?.hashtags,
                SectionContent.urls.rawValue: tweet?.urls,
                SectionContent.users.rawValue: tweet?.userMentions
            ]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        if indexPath.section == SectionContent.urls.rawValue {
            let url = URL(string: (selectedCell?.textLabel?.text)!)
            openURLInSafari(url!)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == SectionContent.image.rawValue {
            // do nothing, storyboard segue
        } else {
            if let tweetTableViewController = storyboard?.instantiateViewController(withIdentifier: "TweetTableViewController") as? TweetTableViewController {
                let selectedString = tableView.cellForRow(at: indexPath)?.textLabel?.text
                tweetTableViewController.searchText = selectedString
                navigationController?.pushViewController(tweetTableViewController, animated: true)
            }
        }
    }
    
    func openURLInSafari(_ url: URL) {
        let sfSafariVC = SFSafariViewController(url: url)
        present(sfSafariVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SectionContent.image.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.imageCellIdentifier, for: indexPath) as! ImageTableViewCell
            
            if let tweetImageUrl = tweet?.media[indexPath.row].url {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if let image = appDelegate.cache.object(forKey: tweetImageUrl as NSURL) {
                    cell.tweetImageView?.image = image
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    DispatchQueue.global(qos: .default).async {
                        if let imageData = NSData(contentsOf: tweetImageUrl) {
                            let downloadedImage = UIImage(data: imageData as Data)
                            self.saveImageToCache(image: downloadedImage!, fromURL: tweetImageUrl)
                            DispatchQueue.main.async {
                                cell.tweetImageView?.image = downloadedImage
                                tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
                
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.textCellIdentifier, for: indexPath)
            if indexPath.section == SectionContent.users.rawValue {
                cell.textLabel?.text = indexPath.row == 0 ? "@\(tweet!.user.screenName)": textCellDictionary[indexPath.section]??[indexPath.row - 1].keyword
            }
            else {
                cell.textLabel?.text = textCellDictionary[indexPath.section]??[indexPath.row].keyword
            }
            return cell
        }
    }
    
    private func saveImageToCache(image: UIImage, fromURL url: URL) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let imageNSURL = url as NSURL
        if appDelegate.cache.object(forKey: imageNSURL) == nil {
            appDelegate.cache.setObject(image, forKey: imageNSURL)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionContent.image.rawValue {
            let selectedCell = tableView.cellForRow(at: indexPath) as? ImageTableViewCell
            if let image = selectedCell?.tweetImageView?.image {
                let aspect = (image.size.width) / (image.size.height)
                let cellHeight = tableView.frame.width / aspect
                return cellHeight
            } else {
                return UITableViewAutomaticDimension
            }
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let numberOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: section)
        if numberOfRowsInSection > 0 {
            switch section {
            case SectionContent.hashTags.rawValue:
                return "HashTags"
            case SectionContent.image.rawValue:
                return "Images"
            case SectionContent.urls.rawValue:
                return "Urls"
            case SectionContent.users.rawValue:
                return "Users"
            default:
                return ""
            }
        }
        return nil
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.searchTweetSegue {
            let tweetTableViewController = segue.destination as! TweetTableViewController
            let selectedString = (sender as? UITableViewCell)?.textLabel?.text
            tweetTableViewController.searchText = selectedString
        } else if segue.identifier == StoryBoard.showImageSegue {
            let imageViewController = segue.destination as! ImageViewController
            let selectedImage = (sender as? ImageTableViewCell)?.tweetImageView?.image
            imageViewController.image = selectedImage
        }
    }
    
}




