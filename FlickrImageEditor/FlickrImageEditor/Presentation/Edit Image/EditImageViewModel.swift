//
//  EditImageViewModel.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

import UIKit
import Combine

class EditImageViewModel: ViewModel<EditImageState> {
    
    // MARK: - Navigation Action

    var didShareImage: ((UIImage, Any) -> Void)?
    
    var didFailToFetchImage: ((String) -> Void)?
    
    // MARK: - Services
    
    private let imageService: ImageService
    
    // MARK: - Data
    
    private var imageMetadata: FlickrImage
    
    // MARK: - State
    
    var statePublisher: AnyPublisher<EditImageState, Never> {
        return state.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(imageService: ImageService, flickrImage: FlickrImage, thumbnail: UIImage? = nil) {
        self.imageService = imageService
        self.imageMetadata = flickrImage
        super.init()
        self.setThumbnailImageIfAvailable(thumbnail: thumbnail)
    }
    
    // MARK: - Actions
    
    func viewLoaded() {
        fetchFullSizeImage()
    }
    
    func shareButtonTapped(from sender: Any) {
        getState { self.didShareImage?($0.image, sender) }
    }
    
    // TODO: - Add editing actions
    
    // MARK: - Private
    
    private func setThumbnailImageIfAvailable(thumbnail: UIImage?) {
        if let thumbnail = thumbnail {
            setState { $0 = EditImageState(title: self.imageMetadata.title, image: thumbnail) }
        }
    }
    
    private func fetchFullSizeImage() {
        setState { $0.isLoading = true } // start loading indicator
        // get image
        imageService.getImage(from: URL(string: imageMetadata.fullImageUrl)!) { response in
            self.setState { $0.isLoading = false } // stop loading indicator
            
            switch response {
            case .success(image: let image):
                self.setState { $0.image = image }
            case .failure(error: let error):
                let errorMessage = error.description
                self.didFailToFetchImage?(errorMessage)
            }
        }
    }
    
}
