//
//  PhotoCell.swift
//  AppObjectRecognizer
//
//  Created by APPLE on 09/06/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    lazy var photoImage: UIImageView = {
        let image: UIImageView = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 8.0
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    //MARK: Life Cycle
    
    public func configureCell(image: UIImage) {
        /// Aplicamos la jerarquia de vistas y propiedades
        self.setViewsHierarchy()
        /// Pintamos la foto
        self.setImage(image: image)
        /// Fijamos las constraints de los elementos
        self.setConstraints()
    }

    
    // MARK: Functions
        
    fileprivate func setViewsHierarchy() {
        self.addSubview(self.photoImage)
    }
    
    fileprivate func setImage(image: UIImage) {
        DispatchQueue.main.async {
            self.photoImage.image = image
            self.photoImage.setNeedsLayout()
        }
    }
    
    fileprivate func setConstraints() {
        NSLayoutConstraint.activate([
            self.photoImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.photoImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.photoImage.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.photoImage.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
}
