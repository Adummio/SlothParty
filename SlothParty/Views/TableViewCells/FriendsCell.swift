//
//  UpcomingEventCell.swift
//  SlothParty
//
//  Created by Carlos Bystron on 11.05.20.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {
    
    let card = UIView()
    let friendImage = UIImageView()
    let nameLabel = UILabel()
    
    func showFriend(name: String) {
        
        backgroundColor = .clear
        selectionStyle = .none
                
        friendImage.backgroundColor = .slothPrimary
        friendImage.layer.cornerRadius = 24
        friendImage.layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        friendImage.layer.shadowOpacity = 0.15
        friendImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        friendImage.layer.shadowRadius = 3
        
        nameLabel.text = name
        
        let views = [card, friendImage, nameLabel]
        views.forEach{self.addSubview($0)}
        
        card.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 80))
        
        friendImage.anchor(top: card.topAnchor, leading: card.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 22, left: 20, bottom: 0, right: 0), size: .init(width: (friendImage.layer.cornerRadius)*2, height: (friendImage.layer.cornerRadius)*2))
        friendImage.centerYInSuperview()
        
        nameLabel.anchor(top: friendImage.topAnchor, leading: friendImage.trailingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 3, left: 25, bottom: 0, right: 90))
        nameLabel.centerYInSuperview()
    }

}
