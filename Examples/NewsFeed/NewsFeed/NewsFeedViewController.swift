//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Alex Manzella on 08/07/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SnapKit
import Kakapo

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var manager: Manager = {
        let configuration: NSURLSessionConfiguration = {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.protocolClasses = [KakapoServer.self]
            return configuration
        }()
        
        return Manager(configuration: configuration)
    }()
    
    var posts: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(PostTableViewCell.self, forCellReuseIdentifier: String(PostTableViewCell))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        requestNewsFeed()
    }
    
    private func requestNewsFeed() {
        manager.request(.GET, "https://kakapobook.com/api/users/\(loggedInUser.id)/newsfeed").responseJSON { [weak self] (response) in
            guard let data = response.data else { return }
            let json = JSON(data: data)
            self?.posts = json.arrayValue.map { (post) -> Post in
                return Post(json: post)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(PostTableViewCell), forIndexPath: indexPath) as! PostTableViewCell
        let post = posts[indexPath.item]
        cell.configure(with: post)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

