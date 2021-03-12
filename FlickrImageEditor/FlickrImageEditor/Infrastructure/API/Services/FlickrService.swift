//
//  FlickrService.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import Foundation

struct FlickrService {
    
    fileprivate let globalQueue = DispatchQueue.global()
    
    fileprivate func getResponse(for url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession(configuration: .default).dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getRecentImages(url: URL = Endpoints.getRecent.asURL, withCompletion completionHandler: @escaping (RecentResponse) -> Void) {
        globalQueue.async(qos: .userInitiated) {
            getResponse(for: url) { (data, urlResponse, error) in
                guard error == nil, let data = data else {
                    completionHandler(.failure(error: .failedToRetrieveResult))
                    return
                }
                
                guard let recentImages = FlickrImage.Factory.recentImages(from: data) else {
                    completionHandler(.failure(error: .failedToParseResponse))
                    return
                }

                completionHandler(.success(recentImages: recentImages))
            }
        }
    }

}

extension FlickrService {
    
    enum Constants {
        static let baseURL = URL(string: "https://api.flickr.com")!
        static let apiKey = "1c78ca5963fe2eb7e18e6a98e171e2d5"
        static let thumbnailUrlKey = "url_q"
        static let fullImageUrlKey = "url_z"
    }
    
    enum Endpoints {
        case getRecent
        
        var path: String {
            switch self {
            case .getRecent:
                let apiKey = FlickrService.Constants.apiKey
                let extras = [FlickrService.Constants.thumbnailUrlKey, FlickrService.Constants.fullImageUrlKey].joined(separator: ",")
                return "/services/rest/?method=flickr.photos.getRecent&format=json&api_key=\(apiKey)&extras=\(extras)"
            }
        }
        
        var asURL: URL {
            return URL(string: self.path, relativeTo: FlickrService.Constants.baseURL)!
        }

    }
    
    enum FlickrAPIError: Error {
        case failedToRetrieveResult
        case failedToParseResponse
    }
    
    enum RecentResponse {
        case success(recentImages: [FlickrImage])
        case failure(error: FlickrAPIError)
    }

}
