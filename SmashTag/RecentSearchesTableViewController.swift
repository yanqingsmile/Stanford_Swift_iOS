//
//  RecentSearchesTableViewController.swift
//  SmashTag
//
//  Created by Vivian Liu on 12/25/16.
//  Copyright © 2016 Vivian Liu. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    var searchedTexts: [String?]? {
        return UserDefaults.standard.object(forKey: "searchedTexts") as? [String?]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        addBackToRootButton()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchedTexts!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchTableViewCell", for: indexPath)
        cell.textLabel?.text = searchedTexts?[indexPath.row]
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let tweetTableViewController = segue.destination as! TweetTableViewController
        let selectedString = (sender as? UITableViewCell)?.textLabel?.text
        tweetTableViewController.searchText = selectedString
    }
}
