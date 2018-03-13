//
//  Image+Extenstion.swift
//  ImageVideoPicker
//
//  Created by Ion Utale on 11/03/2018.
//  Copyright © 2018 ion.utale. All rights reserved.
//

import UIKit

extension UIImage {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveToDocuments(with name: String, type: String) {
        if let data = UIImageJPEGRepresentation(self, 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(name).\(type)")
            try? data.write(to: filename)
            print("image: \(name).\(type) - saved to documents directory")
        }
    }
}
