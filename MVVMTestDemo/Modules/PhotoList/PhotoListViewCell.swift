//
//  PhotoListViewCell.swift
//  MVVMTestDemo
//
//  Created by QDSG on 2019/12/4.
//  Copyright © 2019 unitTao. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoListViewCell: UITableViewCell {
    
    static let reuseIdentifier = "photoListViewCellId"

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func configure(with viewModel: PhotoListCellViewModel) {
        nameLabel.text = viewModel.title
        descLabel.text = viewModel.description
        dateLabel.text = viewModel.dateText
        iconView.kf.indicatorType = .activity
        iconView.kf.setImage(with: URL(string: viewModel.imageUrl))
    }

}
