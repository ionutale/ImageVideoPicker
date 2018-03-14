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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func saveImageToFile() {
        print("save image button action")
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
        
        for asset in assets {
            ImageVideoPicker.getDataFrom(asset: asset) { (data) in
                if data == nil {
                    print(data as Any, self.returnMediaType(mediaType: asset.mediaType), asset.localIdentifier)
                } else {
                    print(data!.count as Any, self.returnMediaType(mediaType: asset.mediaType), asset.localIdentifier)
                }
            }
        }
        collectionView.reloadData()
    }
    
    func returnMediaType (mediaType: PHAssetMediaType) -> String {
        switch mediaType {
        case .audio:
            return "audio"
        case .image:
            return "image"
        case .video:
            return "video"
        default:
            return "bohh type"
        }
    }
}

