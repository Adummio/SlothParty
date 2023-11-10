//
//  RanksVC.swift
//  SlothParty
//
//  Created by Carlos Bystron on 08.05.20.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit

class RanksVC: UIViewController, UISearchBarDelegate {

    //  MARK: - PROPERTIES
        
        let segmentedControl: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["Friends", "Rank"])
            sc.selectedSegmentIndex = 0
            sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
            
            // FIXME: Some hack needed to get rid of the gray background
            sc.backgroundColor = .slothBackground
            
            sc.selectedSegmentTintColor = .slothPrimary
            sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            return sc
        }()
        
        let tableView = UITableView(frame: .zero, style: .plain)
        
        let rank = ["First ranked friend", "Second ranked friend", "Third ranked friend"]
        let friends = ["Friend one", "Friend two", "Friend three"]
        
        lazy var rowsToDisplay = friends
        
        //  MARK: - LIFECYCLE METHODS

        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupNavBar()
            showSearchBar()
            setupTableView()
            
            view.backgroundColor = .slothBackground

            let paddedStackView = UIStackView(arrangedSubviews: [segmentedControl])
            paddedStackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
            paddedStackView.isLayoutMarginsRelativeArrangement = true
                
            let stackView = UIStackView(arrangedSubviews: [paddedStackView, tableView])
            stackView.axis = .vertical
                
            view.addSubview(stackView)
            stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .zero)

        }
        
        //  MARK: - METHODS
        
        func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .singleLine
            tableView.backgroundColor = .clear
            tableView.register(FriendsCell.self, forCellReuseIdentifier: "FriendsCell")
            tableView.register(RanksCell.self, forCellReuseIdentifier: "RanksCell")
        }
          
        @objc fileprivate func handleSegmentChange() {
            
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                rowsToDisplay = friends
                navigationItem.title = "Friends"
            default:
                rowsToDisplay = rank
                navigationItem.title = "Ranks"
            }
              
            tableView.reloadData()
        }
        
        //  MARK: - NavBar Setup
        
        func setupNavBar() {
            let navBar = navigationController?.navigationBar
            
            navBar?.prefersLargeTitles = true
            navBar?.isTranslucent = true
            navBar?.tintColor = .slothPrimary
            
            // Configures the navbars appearance
            let appearance = UINavigationBarAppearance()
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.slothPrimary]
            appearance.configureWithTransparentBackground()
            
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            navigationItem.compactAppearance = appearance
            
            navigationItem.title = "Friends"
        }
        
        func showSearchBar() {
            let searchController = UISearchController(searchResultsController: nil)
            
            searchController.searchBar.delegate = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = true
            
            // FIXME: Scrolling behaviour for the searchbar + styling
            navigationItem.hidesSearchBarWhenScrolling = true
            
            searchController.searchBar.sizeToFit()
            searchController.searchBar.returnKeyType = UIReturnKeyType.search
            searchController.searchBar.placeholder = "Search a Friend"
            
            navigationItem.searchController = searchController
        }
    }

    extension RanksVC: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              return rowsToDisplay.count
        }
          
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            switch rowsToDisplay {
            case friends:
                let friendsCell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell",  for: indexPath) as! FriendsCell
                friendsCell.showFriend(name: rowsToDisplay[indexPath.row])
                return friendsCell
            default:
                let rankCell = tableView.dequeueReusableCell(withIdentifier: "RanksCell",  for: indexPath) as! RanksCell
                rankCell.showFriend(name: rowsToDisplay[indexPath.row])
                return rankCell
            }
        
        }

}
