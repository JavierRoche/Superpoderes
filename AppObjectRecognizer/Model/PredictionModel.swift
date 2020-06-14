//
//  PredictionModel.swift
//  AppObjectRecognizer
//
//  Created by APPLE on 10/06/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import Vision
import QuartzCore
import UIKit

protocol PredictionModelDelegate: class {
    func didPredict(predictions: [VNRecognizedObjectObservation]?, photos: [UIImage]?)
}

/// Se encarga de comunicarse con el modelo y hacerle las request
class PredictionModel {
    /// Para devolver la informacion al viewController
    weak var delegate: PredictionModelDelegate?
    
    /// Creamos la instancia de nuestro modelo con su mismo nombre
    private let YOLOmodel: YOLOv3 = YOLOv3()
    /// Flag para usar Vision o acceso directo al modelo
    var useVision: Bool = true
    /// Tamaño maximo de la imagen
    private let maxImageSize: CGFloat = 416
    /// Flag de control para analizar las fotos de una en una
    private var isPredicting = false
    /// Para la busqueda masiva
    private var text: String = ""
    private var index: Int = 0
    private var massiveRequest: Bool = false
    private var images: [UIImage]?
    /// El tipo necesario para atacar al modelo con Vision es VNCoreMLRequest
    private var request: VNCoreMLRequest?
    
    
    // MARK: Life Cycle
    
    /// El init opcional porque para Core Machine Learning no necesita inicializacion
    init?() {
        /// Inicializamos el modelo y la request con el modelo para Vision. Core Machine Learning no lo necesita
        if let visionModel: VNCoreMLModel = try? VNCoreMLModel(for: self.YOLOmodel.model) {
            /// Cuando la request termine se ejecutara el completionHandler
            self.request = VNCoreMLRequest(model: visionModel, completionHandler: self.visionRequestCompleted)
            self.request?.imageCropAndScaleOption = .scaleFill
            
        } else {
            fatalError("fail to create vision model")
        }
    }
    
    /// Metodo publico que recibe para identificar una imagen o un texto en todas las imagenes
    func predict(pixelBufferImage: CVPixelBuffer?, text: String?) {
        /// Nos aseguramos de que no estamos ya trabajando con otra imagen y bloqueamos otro acceso
        guard !isPredicting else { return }
        self.isPredicting = true
        /// Para que no nos pare la aplicacion mientras Vision reconoce tenemos que mandarlo al Globalqueue
        let predictionQueue = DispatchQueue(__label: "predicciones", attr: nil)
        
        /// Si estamos en una prediccion individual
        guard let searchedText: String = text else {
            guard let pixelBufferImage: CVPixelBuffer = pixelBufferImage else { return }
            predictionQueue.async { [weak self] in
                self?.useVision ?? true ? self?.predictWithVision(pixelBufferImage) : self?.predictWithCoreML(pixelBufferImage)
            }
            return
        }
        
        /// Si estamos en una prediccion masiva
        self.index = 0
        self.text = searchedText
        self.massiveRequest = true
        self.images = []
        ViewController.photos.forEach { [weak self] photo in
            /// Transformamos la UIImage en CVPixelBuffer para enviarla al modelo
            guard let pixelBufferImage: CVPixelBuffer = photo.pixelBuffer else { return }
            /// Decidimos si atacamos al modelo con Vision o Core ML
            predictionQueue.async {
                self?.useVision ?? true ? self?.predictWithVision(pixelBufferImage) : self?.predictWithCoreML(pixelBufferImage)
            }
        }
    }
    
    
    // MARK: Core Matching Learning
    
    /// Metodo de prediccion de Core Machine Learning. Recibe un CVPixelBuffer
    fileprivate func predictWithCoreML(_ pixelBuffer: CVPixelBuffer) {
        /// TODO
    }
    
    
    // MARK: Vision
    
    fileprivate func predictWithVision(_ pixelBuffer: CVPixelBuffer) {
        /// En Vision tenemos que crear un VNImageRequestHandler pasandole el CVPixelBuffer
        let handler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        /// Y con el handler intentamos ejecutar la request
        guard let visionRequest = self.request else { return}
        try? handler.perform([visionRequest])
    }
    
    fileprivate func visionRequestCompleted(request: VNRequest, error: Error?) {
        /// Los resultados de este modelo se reciben en un [VNClassificationObservation]
        guard let predictions = request.results as? [VNRecognizedObjectObservation] else {
            self.restartModel()
            return
        }
        
        if self.massiveRequest {
            /// Recorre las predicciones de cada imagen y añade la imagen al array de filtrados...
            var filteredImages: [UIImage] = []
            for prediction in predictions {
                print(prediction.labels.first?.identifier ?? "")
                /// ...si alguna prediccion coincide con la palabra buscada
                if prediction.labels.first?.identifier == self.text {
                    filteredImages.append(ViewController.photos[self.index])
                    break
                }
            }
            self.images? += filteredImages; print(self.index); print(self.images?.count ?? "")
            
            /// Evita que se avise al delegado hasta terminar con las 100 imagenes
            if self.index != 99 { self.index += 1; return }
        }
        
        DispatchQueue.main.async { [weak self] in
            /// Avisamos al ViewController pasandole las el nuevo array de imagenes
            self?.delegate?.didPredict(predictions: predictions, photos: self?.images)
            /// Preparamos el modelo para la siguiente imagen
            self?.restartModel()
        }
    }
    
    fileprivate func restartModel() {
        self.isPredicting = false
        self.massiveRequest = false
        self.images = nil
    }
}
