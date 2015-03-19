//
//  EventCell.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/18/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit

protocol EventCellProtocoll {
    func onLocationButtonTapped(indexPathAt myIndexPath: NSIndexPath)
}

class EventCell: UITableViewCell{
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    var delegate: EventCellProtocoll?
    var indexPath: NSIndexPath?
    
    @IBAction func locationButtonTapped(sender: AnyObject) {
        if self.delegate != nil && self.indexPath != nil {
            self.delegate?.onLocationButtonTapped(indexPathAt: self.indexPath!)
        }
    }
    
}
