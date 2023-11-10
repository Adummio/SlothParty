//
//  UpcomingEventCell.swift
//  SlothParty
//
//  Created by Carlos Bystron on 11.05.20.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit

class InvitationEventCell: UITableViewCell {
    
    let card = UIView()
    let eventImage = UIImageView()
    let title = UILabel()
    let group = UILabel()
    let address = UILabel()
    let day = UILabel()
    let month = UILabel()
    let time = UILabel()
    
    func showEvent(name: String) {
        
        backgroundColor = .clear
        selectionStyle = .none
        
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 17
        card.layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 5
        
        eventImage.backgroundColor = .slothPrimary
        eventImage.layer.cornerRadius = 33
        
        title.text = name
        group.text = name
        address.text = name
        
        day.text = "24"
        month.text = "Mar"
        time.text = "17:00"
        
        let views = [card, eventImage, title, group, address, day, month, time]
        views.forEach{self.addSubview($0)}
        
        card.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 7, left: 14, bottom: 7, right: 14), size: .init(width: 0, height: 190))
        
        eventImage.anchor(top: card.topAnchor, leading: card.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 22, left: 20, bottom: 0, right: 0), size: .init(width: 66, height: 66))
        
        title.anchor(top: eventImage.topAnchor, leading: eventImage.trailingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 3, left: 10, bottom: 0, right: 90))
        group.anchor(top: title.bottomAnchor, leading: title.leadingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 90))
        address.anchor(top: group.bottomAnchor, leading: group.leadingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 90))
        
        day.anchor(top: eventImage.topAnchor, leading: nil, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 3, left: 0, bottom: 0, right: 20))
        month.anchor(top: day.bottomAnchor, leading: nil, bottom: nil, trailing: day.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        time.anchor(top: month.bottomAnchor, leading: nil, bottom: nil, trailing: day.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }

}
