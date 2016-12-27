//
//  DetailTableViewController.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/18/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit
import Twitter

class DetailTableViewController: UITableViewController {
    
        
    var tweet: Twitter.Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tweet detail"
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        print(tweet)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionContent.image.rawValue:
            return (tweet?.media.count)!
        case SectionContent.hashTags.rawValue:
            return (tweet?.hashtags.count)!
        case SectionContent.urls.rawValue:
            return (tweet?.urls.count)!
        case SectionContent.users.rawValue:
            return (tweet?.userMentions.count)!
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
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == SectionContent.image.rawValue {
            // do nothing, storyboard segue
        } else {
            performSegue(withIdentifier: "searchTweetSegue", sender: selectedCell)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SectionContent.image.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.imageCellIdentifier, for: indexPath) as! ImageTableViewCell
            if let tweetImageUrl = tweet?.media[indexPath.row].url {
                DispatchQueue.global(qos: .default).async {
                    if let imageData = NSData(contentsOf: tweetImageUrl) {
                        DispatchQueue.main.async {
                            cell.tweetImageView?.image = UIImage(data: imageData as Data)
                            tableView.reloadData()
                        }
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.textCellIdentifier, for: indexPath)
            cell.textLabel?.text = textCellDictionary[indexPath.section]??[indexPath.row].keyword
            return cell
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
