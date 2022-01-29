//
//  NetworkService.swift
//  BuscarFotos
//
//  Created by Guike on 28/01/22.
//

import Foundation
import UIKit

typealias JSON = [String: Any]

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    let baseURL = "https://api.imgur.com/3"
    let session = URLSession.shared
    var currentPage: Int = 0
    var searchText: String = ""
    
    func fetchPhotos(query: String, success successBlock: @escaping (GetImgursResponse) -> Void) {
        searchText = query
        let urlString = "\(baseURL)/gallery/search/\(currentPage)?q=\(query)&q_size_px=small&q_type=png"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Client-ID " + Key.clientId, forHTTPHeaderField: "Authorization")
        
       session.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
           
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else { return }
                let getImgursResponse = try GetImgursResponse(json: json)
                DispatchQueue.main.async {
                    successBlock(getImgursResponse)
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func nextPage(success successBlock: @escaping ([ImgurModel]) -> Void) {
        currentPage += 1
        fetchPhotos(query: searchText, success: { (response) in
            successBlock(response.imgurs)
        })
    }
    
    func downloadImage(fromLink link: String, success successBlock: @escaping (UIImage) -> Void) {
        guard let url = URL(string: link) else { return }
        session.dataTask(with: url) { (data, _, _) in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                successBlock(image)
            }
        }.resume()
    }
}
