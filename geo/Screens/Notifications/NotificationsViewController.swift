//
//  NotificationsViewController.swift
//  geo
//
//  Created by Andrey on 30.01.2023.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    private let friendsService = FriendsService.self
    private var friendshipRequests = [FriendshipRequest]()
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet private var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupRefreshControl()
        setupStyling()
        
        updateFriendshipRequests()
    }
    
    private func updateFriendshipRequests() {
        friendsService.getFriendshipRequests(type: .incoming) { result in
            switch result {
            case .success(let friendshipRequests):
                self.friendshipRequests = friendshipRequests
                
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.table.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupTable() {
        table.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = false
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    private func setupStyling() {
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        updateFriendshipRequests()
    }
}

extension NotificationsViewController: UITableViewDelegate {
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendshipRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.setup(
            notification: friendshipRequests[indexPath.row]
        ) { [weak self] request, confirmed in
            self?.friendsService.answerOnFriendshipRequest(
                senderID: request.sender.id,
                accept: confirmed
            ) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.updateFriendshipRequests()
            }
        }
        return cell
    }
}
