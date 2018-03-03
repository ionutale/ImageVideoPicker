//
//  MainViewController.swift
//  ImageVideoPicker
//
//  Created by Ion Utale on 03/03/2018.
//  Copyright © 2018 ion.utale. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addImages: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImageVideoPickerCell", bundle: nil), forCellWithReuseIdentifier: "asset")

    }
}

extension MainViewController: UICollectionViewDelegate {}
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageVideoPickerCell", for: indexPath)
        
        return cell
    }
}

