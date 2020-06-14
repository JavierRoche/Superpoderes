//
//  ViewController.swift
//  AppObjectRecognizer
//
//  Created by APPLE on 09/06/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    private let textPhoto: String = "photo"
    static var photos: [UIImage] = []
        
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160.0, height: 160.0)
        layout.minimumInteritemSpacing = 16.0
        layout.sectionInset = UIEdgeInsets(top: 32.0, left: 32.0, bottom: 32.0, right: 32.0)
        return layout
    }()
        
    lazy var collectionView: UICollectionView = {
        let collection: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor.white
        collection.delegate = self
        collection.dataSource = self
        collection.register(PhotoCell.self, forCellWithReuseIdentifier: String(describing: PhotoCell.self))
        return collection
    }()
        
    lazy var searchController: UISearchController = {
        let search: UISearchController = UISearchController()
        search.searchBar.searchTextField.clearButtonMode = .never
        search.searchBar.delegate = self
        search.obscuresBackgroundDuringPresentation = false
        search.automaticallyShowsCancelButton = true
        return search
    }()
    
    lazy var switchButton: UISwitch = {
        let switchy: UISwitch = UISwitch()
        switchy.isOn = true
        switchy.addTarget(self, action: #selector(switchDidChanged), for: .valueChanged)
    
        return switchy
    }()
    
    lazy var switchLabel: UILabel = {
        let label: UILabel = UILabel()
        label.frame = CGRect(x: 0.0, y: 0.0, width: 80, height: 20)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .right
        label.text = "Vision"
        return label
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.orange
        indicator.style = UIActivityIndicatorView.Style.large
        return indicator
    }()
    
        
    // MARK: Life Cycle
        
    override func loadView() {
        self.view = UIView()
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuramos la interface y cargamos las fotos en el CollectionView
        self.configureUI()
        self.loadPhotos()
    }
        
        
    // MARK: Functions
    
    fileprivate func configureUI() {
        /// Asignacion del UISearchController y atributos del navigationController
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Catalogo"
        
        /// Creacion del switch para usar Vision o Core ML
        let switchButton: UIBarButtonItem = UIBarButtonItem(customView: self.switchButton)
        let switchLabel: UIBarButtonItem = UIBarButtonItem(customView: self.switchLabel)
        self.navigationItem.rightBarButtonItems = [switchButton, switchLabel]
    }

    fileprivate func loadPhotos() {
        ViewController.photos = []
        for index in 1...100 {
            guard let image: UIImage = UIImage(named: "\(self.textPhoto)\(index)") else { return }
            ViewController.photos.append(image)
        }
    }
    
    @objc func switchDidChanged(sender: UISwitch!) {
        self.switchLabel.text = sender.isOn ? "Vision" : "Core ML"
        //Manager.predictionModel?.useVision = false  <-- Cuando implemente Core ML
    }
}


// MARK: PredictionModel Delegate

extension ViewController: PredictionModelDelegate  {
    func didPredict(predictions: [VNRecognizedObjectObservation]?, photos: [UIImage]?) {
        /// Cuando termina cada prediccion mostramos la lisa buscada si se nos ha devuelto
        guard let photos = photos else { return }
        ViewController.photos = photos
        self.collectionView.reloadData()
        
        /// Paramos la animacion y liberamos el uso del searchController y del resto de la interface
        self.searchController.searchBar.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}


// MARK: UICollectionView Delegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// Presentamos el detalle de la imagen seleccionada
        let detailPhoto: PhotoDetail = PhotoDetail.init(photo: ViewController.photos[indexPath.row])
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: detailPhoto)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.isHidden = true
        self.present(navigationController, animated: true, completion: nil)
        /// Deseleccionamos el item
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
    

// MARK: UICollectionView DataSource

extension ViewController: UICollectionViewDataSource {
    /// Funcion delegada del numero de items del CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViewController.photos.count
    }
    
    /// Funcion delegada de rellenado del CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as? PhotoCell {
            cell.configureCell(image: ViewController.photos[indexPath.row])
            return cell
        }
        fatalError("Couldn't create cells")
    }
}


// MARK: UISearchControll / UISearchBar Delegate

extension ViewController: UISearchBarDelegate  {
    /// Funcion delegada de UISearchBar para controlar el click en Enter o Buscar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text: String = self.searchController.searchBar.text?.lowercased() else { return }
        if text != "" {
            print("Buscar: \(text)")
            /// Bloqueamos el uso del searchController y resto de la pantalla para la busqueda actual
            searchController.searchBar.isUserInteractionEnabled = false
            self.view.isUserInteractionEnabled = false
            /// Iniciamos la animacion de waiting
            self.activityIndicator.center = self.view.center
            self.activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
                
            /// Enviamos al modelo el texto de busqueda
            Manager.predictionModel?.delegate = self
            Manager.predictionModel?.predict(pixelBufferImage: nil, text: text)
        }
    }
    
    /// Funcion delegada de UISearchBar para controlar el click en Cacel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        /// Vaciamos la caja de busqueda porque un funcionamiento que no conozco rellama a searchBarTextDidEndEditing despues de searchBarCancelButtonClicked, y como haya algo escrito pues se pone a hacer la busqueda masiva
        self.searchController.searchBar.text = ""
        /// Cargamos todas las fotos de nuevo
        self.loadPhotos()
        self.collectionView.reloadData()
    }
}
