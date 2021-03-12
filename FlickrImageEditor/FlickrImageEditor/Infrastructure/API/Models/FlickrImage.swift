//
//  FlickrImage.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import Foundation

struct FlickrImage: Equatable {
    let id: String
    let title: String
    let thumbnailUrl: String
    let fullImageUrl: String
}

extension FlickrImage {
    
    enum Factory {
        
        static func recentImages(from data: Data) -> [FlickrImage]? {
            guard let responseString = String(bytes: data, encoding: .utf8) else { return nil }
            let trimmedJson = String(responseString.dropFirst(14).dropLast())
            guard let json = trimmedJson.data(using: .utf8) else { return nil }

            var response: Any? = nil
            do { response = try JSONSerialization.jsonObject(with: json, options:[]) }
            catch { print("\(error)") }

            guard let responseDictionary = response as? [String : Any],
                  let photosPaged = responseDictionary["photos"] as? [String : Any],
                  let photos = photosPaged["photo"] as? [[String : Any]] else { return nil }
            
            let parsedPhotos = photos.reduce(into: [FlickrImage]()) { parsedArray, photoDictionary in
                guard let id = photoDictionary["id"] as? String,
                      let title = photoDictionary["title"] as? String,
                      let thumbnailUrl = photoDictionary[FlickrService.Constants.thumbnailUrlKey] as? String,
                      let fullImageUrl = photoDictionary[FlickrService.Constants.fullImageUrlKey] as? String else { return }
                parsedArray.append(FlickrImage(id: id, title: title, thumbnailUrl: thumbnailUrl, fullImageUrl: fullImageUrl))
            }
            
            return parsedPhotos
        }
        
    }
    
}
