//
//  ImageCollectionViewCell.swift
//  DeltaTask
//
//  Created by Dinesh Kumar 16 on 5/29/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell,ReusableView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    
    /// Setting Collection Cell UI with Image Details
    ///
    /// - Parameter imageData: <#imageData description#>
    func configImageCell(imageData:ImageDataModel){
        imageNameLabel.text = imageData.name ?? ""
        if let url = URL(string: imageData.image ?? "") {
            image.image = #imageLiteral(resourceName: "download")
            image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "download"), options: .delayPlaceholder, completed: nil)
            image.backgroundColor = .lightGray
        } else {
            image.image = #imageLiteral(resourceName: "download")
        }
    }
}
