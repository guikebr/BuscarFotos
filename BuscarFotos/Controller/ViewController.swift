//
//  ViewController.swift
//  BuscarFotos
//
//  Created by Guike on 27/01/22.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    private var collectionView: UICollectionView?
    private var imgurs: [ImgurModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.fadeView.removeFromSuperview()
                self.activityView.stopAnimating()
            }
        }
    }
    
    let activityView = UIActivityIndicatorView(style: .large)
    let searchbar = UISearchBar()
    let fadeView:UIView = UIView()
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       // create a hover view that covers all screen with opacity 0.4 to show a waiting action
        fadeView.frame = self.view.frame
        fadeView.backgroundColor = UIColor.white
        fadeView.alpha = 0.4

       // add fade view to main view
        self.view.addSubview(fadeView)
        // add activity to main view
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        // start animating activity view
        activityView.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSeachBar()
        setupCollectionView()
        NetworkService.shared.fetchPhotos(query: "random", success: { (response) in
            self.imgurs.append(contentsOf: response.imgurs)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageCache.removeAllObjects()
    }
    
    private func setupSeachBar() {
        searchbar.delegate = self
        view.addSubview(searchbar)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/4, height: view.frame.size.width/4)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchbar.text {
            imgurs = []
            // start animating activity view
            activityView.startAnimating()
            NetworkService.shared.fetchPhotos(query: text, success: { (response) in
                self.imgurs.append(contentsOf: response.imgurs)
            })
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgurs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath
        ) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imgurs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == imgurs.count - 1) {
            // start animating activity view
            activityView.startAnimating()
            NetworkService.shared.nextPage(success: { (imgurs) in
                self.imgurs.append(contentsOf: imgurs)
            })
        }
   }
}
