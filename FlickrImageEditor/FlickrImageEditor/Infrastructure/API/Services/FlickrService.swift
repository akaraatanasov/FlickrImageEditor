//
//  FlickrService.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import Foundation

enum FlickrAPIError: Error {
    case failedToRetrieveResult
    case failedToParseResponse
}

enum RecentsResponse {
    case success(recentImages: [FlickrImage])
    case failure(error: FlickrAPIError)
}

enum Endpoint {
    case getRecent
    
    var path: String {
        switch self {
        case .getRecent:
            let apiKey = Constants.apiKey
            let extras = [Constants.thumbnailUrlKey, Constants.fullImageUrlKey].joined(separator: ",")
            return "/services/rest/?method=flickr.photos.getRecent&format=json&api_key=\(apiKey)&extras=\(extras)"
        }
    }
    
    var asURL: URL {
        switch self {
        case .getRecent: return URL(string: self.path, relativeTo: Constants.baseURL)!
        }
    }
}

struct FlickrService {
    
    fileprivate let globalQueue = DispatchQueue.global()
    
    fileprivate func getResponse(for url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession(configuration: .default).dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getRecentImages(url: URL = Endpoint.getRecent.asURL, withCompletion completionHandler: @escaping (RecentsResponse) -> Void) {
        globalQueue.async(qos: .userInitiated) {
            getResponse(for: url) { (data, urlResponse, error) in
                guard error == nil, let data = data, let recentImages = recentImagesFrom(data: data) else {
                    completionHandler(.failure(error: .failedToRetrieveResult))
                    return
                }

                completionHandler(.success(recentImages: recentImages))
            }
        }
    }
    
    private func recentImagesFrom(data: Data) -> [FlickrImage]? {
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
                  let thumbnailUrl = photoDictionary[Constants.thumbnailUrlKey] as? String,
                  let fullImageUrl = photoDictionary[Constants.fullImageUrlKey] as? String else { return }
            parsedArray.append(FlickrImage(id: id, title: title, thumbnailUrl: thumbnailUrl, fullImageUrl: fullImageUrl))
        }
        
        return parsedPhotos
    }

}
