//
//  GetImgursResponse.swift
//  BuscarFotos
//
//  Created by Guike on 28/01/22.
//

import Foundation

struct GetImgursResponse {
    let imgurs: [ImgurModel]
    
    init (json: JSON) throws {
        guard let dataJson = json["data"] as? [JSON] else { throw NetworkingError.jsonError }
        let imgurs = dataJson.map{ ImgurModel(json: $0) }.compactMap{ $0 }
        self.imgurs = imgurs
    }
}
