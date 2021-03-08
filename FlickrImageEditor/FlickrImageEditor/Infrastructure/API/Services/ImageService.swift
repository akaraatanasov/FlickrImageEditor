//
//  ImageService.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit

enum ImageError: Error {
    case failedToRetrieveImage
    case failedToDecodeImageFormat
}

enum ImageResponse {
    case success(image: UIImage)
    case failure(error: ImageError)
}

struct ImageService {
    
    fileprivate let globalQueue = DispatchQueue.global()
    
    fileprivate func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getImage(from url: URL, withCompletion completionHandler: @escaping (ImageResponse) -> Void) {
        globalQueue.async(qos: .userInitiated) {
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else {
                    completionHandler(.failure(error: .failedToRetrieveImage))
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    completionHandler(.failure(error: .failedToDecodeImageFormat))
                    return
                }
                
                completionHandler(.success(image: image))
            }
        }
    }

}
