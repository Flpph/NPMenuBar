//
//  ArtworkLoader.swift
//  NPMenuBar
//
//  Created by Attila Szél on 2022. 04. 11..
//

import Foundation
import SwiftUI

class ArtworkLoader {
    private var dataTasks: [URLSessionDataTask] = []
    
    func loadArtwork(artworkUrl: String, completion: @escaping((Image?) -> Void)) {
        guard let imageUrl = URL(string: artworkUrl) else {
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            guard let data = data, let artwork = NSImage(data: data) else {
                completion(nil)
                return
            }
            
            var image = Image(nsImage: artwork)
            image = image.resizable()
            completion(image)
        }
        dataTasks.append(dataTask)
        dataTask.resume()
    }
    
    func reset() {
        dataTasks.forEach {
            $0.cancel()
        }
        dataTasks.removeAll()
    }
}
