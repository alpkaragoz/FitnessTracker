//
//  ImageData.swift
//  FitnessTracker
//
//  Created by Ipek Gokaltun on 25.12.2023.
//

import SwiftUI

class ImageData: ObservableObject {
    var key: String
    @Published var selectedImageData: Data? {
        didSet {
            saveImage()
        }
    }

    init(key: String) {
        self.key = key
        loadImage()
    }

    func saveImage() {
        UserDefaults.standard.set(selectedImageData, forKey: key)
    }

    func loadImage() {
        if let imageData = UserDefaults.standard.data(forKey: key) {
            selectedImageData = imageData
        }
    }

    func loadImageAsImage() -> Image? {
        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
