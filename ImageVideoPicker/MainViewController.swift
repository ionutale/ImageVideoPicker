//
//  MainViewController.swift
//  ImageVideoPicker
//
//  Created by Ion Utale on 03/03/2018.
//  Copyright © 2018 ion.utale. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addImages: UIButton!
    
    var selectedPhotos: [PHAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImageVideoPickerCell", bundle: nil), forCellWithReuseIdentifier: "asset")

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagePicker" {
            let imagePick = segue.destination as! ImageVideoPicker
            imagePick.delegate = self
        }
    }
    
//    if let image = UIImage(named: "example.png") {
//        if let data = UIImagePNGRepresentation(image) {
//            let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
//            try? data.write(to: filename)
//        }
//    } 
//
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func saveImageToFile() {
        if let image = UIImage(named: "example.png") {
            if let data = UIImageJPEGRepresentation(image, 0.8) {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
                try? data.write(to: filename)
            }
    }
    }
}

extension MainViewController: UICollectionViewDelegate {}
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "asset", for: indexPath) as! ImageVideoPickerCell
        cell.asset = selectedPhotos[indexPath.row]
        cell.selection = false

        return cell
    }
}

extension MainViewController: ImageVideoPickerDelegate {
    func onCancel() {
        // not implemented yet
    }
    
    func onDoneSelection(assets: [PHAsset]) {
        selectedPhotos = assets
        collectionView.reloadData()
    }
    
    
}

