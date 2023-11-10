//
//  EventsVC.swift
//  SlothParty
//
//  Created by Carlos Bystron on 09.05.20.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit

class EventsVC: UIViewController, UISearchBarDelegate {
    
    //  MARK: - PROPERTIES
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Events", "Invitations", "Past Events"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
        // FIXME: Some hack needed to get rid of the gray background
        sc.backgroundColor = .slothBackground
        
        sc.selectedSegmentTintColor = .slothPrimary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return sc
    }()
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let events = ["My cool meeting 1", "My cool meeting 2", "My cool meeting 3", "My cool meeting 4"]
    let invitations = ["A event I may join", "Another event I may join"]
    let pastEvents = ["Somewhere I was", "Something I've seen", "The most boring Concert everrrrrrrr", "A fantastic date"]
    
    lazy var rowsToDisplay = events
    
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
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UpcomingEventCell.self, forCellReuseIdentifier: "UpcomingEventCell")
        tableView.register(InvitationEventCell.self, forCellReuseIdentifier: "InvitationEventCell")
        tableView.register(PastEventCell.self, forCellReuseIdentifier: "PastEventCell")
    }
      
    @objc fileprivate func handleSegmentChange() {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rowsToDisplay = events
            navigationItem.title = "Events"
        case 1:
            rowsToDisplay = invitations
            navigationItem.title = "Invitations"
        default:
            rowsToDisplay = pastEvents
            navigationItem.title = "Past Events"
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
        
        // Configures the navbar buttons appearance
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.scrollEdgeAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance // For iPhone small navigation bar in landscape.
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "calendar.badge.plus")!, style: .plain, target: self, action: #selector(action(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        navigationItem.title = "Events"
        
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
        searchController.searchBar.placeholder = "Search Event"
        
        navigationItem.searchController = searchController
    }

    
    // MARK: - Actions
       
    @IBAction func action(_ sender: AnyObject) {
        Swift.debugPrint("CustomRightViewController IBAction invoked")
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddEvent", bundle: nil)
        let addEventVC = storyBoard.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
        self.show(addEventVC, sender: self)
    }
}

extension EventsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return rowsToDisplay.count
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch rowsToDisplay {
        case invitations:
            let invitationCell = tableView.dequeueReusableCell(withIdentifier: "InvitationEventCell",  for: indexPath) as! InvitationEventCell
            invitationCell.showEvent(name: rowsToDisplay[indexPath.row])
            return invitationCell
        case pastEvents:
            let pastCell = tableView.dequeueReusableCell(withIdentifier: "PastEventCell",  for: indexPath) as! PastEventCell
            pastCell.cellNumber = indexPath.row
            pastCell.cellsInTotal = pastEvents.count
            pastCell.showEvent(name: rowsToDisplay[indexPath.row])
            return pastCell
        default:
            let upcomingCell = tableView.dequeueReusableCell(withIdentifier: "UpcomingEventCell",  for: indexPath) as! UpcomingEventCell
            upcomingCell.showEvent(name: rowsToDisplay[indexPath.row])
            return upcomingCell
        }
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "DetailEvent", bundle: nil)
        let detailEventVC = storyBoard.instantiateViewController(withIdentifier: "DetailEventVC") as! DetailEventVC
        self.show(detailEventVC, sender: self)
    }
    
}
