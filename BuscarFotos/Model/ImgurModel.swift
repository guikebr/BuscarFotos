//
//  Imgur.swift
//  BuscarFotos
//
//  Created by Guike on 28/01/22.
//

import UIKit

struct ImgurModel {
    let id: String
    let link: String
    let title: String
    
    init?(json: JSON) {
        guard let id = json["id"] as? String,
              let title = json["title"] as? String,
              let link = json["cover"] as? String
            else { return nil }
        self.id = id
        self.title = title
        self.link = "https://i.imgur.com/\(link).png"
    }
    
    func image(completion: @escaping (UIImage) -> Void) {
        if let image = imageCache.image(forKey: id) {
            completion(image)
        } else {
            NetworkService.shared.downloadImage(fromLink: link) { (image) in
                imageCache.add(image, forKey: self.id)
                completion(image)
            }
        }
    }
}
