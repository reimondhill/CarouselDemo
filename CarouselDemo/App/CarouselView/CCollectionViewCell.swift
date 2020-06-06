//
//  CCollectionViewCell.swift
//  CarouselDemo
//
//  Created by Ramon Haro Marques on 06/06/2020.
//  Copyright © 2020 Ramon Haro Marques. All rights reserved.
//

import UIKit

final class CVCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 40.0)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
