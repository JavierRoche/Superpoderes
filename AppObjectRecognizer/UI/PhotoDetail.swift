//
//  PhotoDetail.swift
//  AppObjectRecognizer
//
//  Created by APPLE on 10/06/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit
import Vision

final class PhotoDetail: UIViewController {
    private var image: UIImage?
    lazy var photoImage: UIImageView = {
        let image: UIImageView = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 16.0
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    //MARK: Life Cycle
    
    convenience init(photo: UIImage) {
        self.init(nibName: String(describing: PhotoDetail.self), bundle: nil)
        self.image = photo
    }
    
    override func loadView() {
        self.view = UIView()
        self.view.addSubview(photoImage)
        
        NSLayoutConstraint.activate([
            self.photoImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.photoImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.photoImage.widthAnchor.constraint(equalToConstant: 416.0),
            self.photoImage.heightAnchor.constraint(equalToConstant: 416.0),
        ])
    }
    
    override func viewDidLoad() {
        guard let photo: UIImage = self.image else { return }
        self.predictionsForImage(image: photo)
        self.photoImage.image = image
    }
    
    
    // MARK: Functions
    
    private func predictionsForImage(image: UIImage) {
        guard let pixelBufferImage = image.pixelBuffer else { return }
        
        /// Enviamos al modelo la imagen de busqueda
        Manager.predictionModel?.delegate = self
        Manager.predictionModel?.predict(pixelBufferImage: pixelBufferImage, text: nil)
    }
}


// MARK: PredictionModel Delegate

extension PhotoDetail: PredictionModelDelegate  {
    /// Funcion delegada a la que llama el modelo de reconocimiento cuando termina entregando las predicciones para ...
    func didPredict(predictions: [VNRecognizedObjectObservation]?, photos: [UIImage]?) {
        /// ... pintar tantas cajas indentificativas como predicciones se hayan realizado
        for prediction in predictions ?? [] {
            let scale = CGAffineTransform.identity.scaledBy(x: self.photoImage.bounds.width , y: self.photoImage.bounds.height)
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1.5)
            let boundingBoxRect: CGRect = prediction.boundingBox.applying(transform).applying(scale)
            
            /// La vista bordeada que encuadra el bounding box de la prediccion
            let boundingBoxView: UIView = UIView(frame: boundingBoxRect)
            boundingBoxView.layer.borderColor = UIColor.green.cgColor
            boundingBoxView.layer.borderWidth = 4
            boundingBoxView.backgroundColor = UIColor.clear
            self.view.addSubview(boundingBoxView)
            
            /// La etiqueta sobre el borde que muestra el identificador
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            label.text = prediction.labels.first?.identifier ?? "N/A"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.green
            label.sizeToFit()
            label.frame = CGRect(x: boundingBoxRect.origin.x, y: boundingBoxRect.origin.y - label.frame.height,
                                 width: label.frame.width, height: label.frame.height)
            self.view.addSubview(label)
        }
    }
}
