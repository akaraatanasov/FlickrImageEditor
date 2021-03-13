//
//  SelectImageViewModel.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit
import Combine

class SelectImageViewModel: ViewModel<SelectImageState> {
    
    // MARK: - Navigation Action

    var didSelectImage: ((FlickrImage, UIImage?) -> Void)?
    
    // MARK: - Services
    
    private let flickrService: FlickrService
    private let imageService: ImageService
    
    // MARK: - Data
    
    private var images: [FlickrImage]
    private var thumbnails: [String: UIImage]
    
    var imagesCount: Int {
        return images.count
    }
    
    // MARK: - State
    
    var statePublisher: AnyPublisher<SelectImageState, Never> {
        return state.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(flickrService: FlickrService, imageService: ImageService) {
        self.flickrService = flickrService
        self.imageService = imageService
        self.images = [FlickrImage]()
        self.thumbnails = [String: UIImage]()
        super.init()
    }
    
    // MARK: - Actions
    
    func viewLoaded() {
        fetchRecentImages()
    }
    
    func refreshButtonTapped() {
        fetchRecentImages()
    }
    
    func imageSelected(at indexPath: IndexPath) {
        let selectedImage = images[indexPath.row]
        let thumbnail = thumbnails[selectedImage.id]
        didSelectImage?(selectedImage, thumbnail)
    }
    
    // MARK: - Cell Configure Method
    
    func configure(_ cell: SelectImageCell, for indexPath: IndexPath) {
        if !images.isEmpty {
            cell.imageTitle = images[indexPath.row].title
        }
        
        cell.startLoading()
        getThumbnail(for: indexPath) { thumbnail in
            cell.stopLoading()
            cell.imageThumbnail = thumbnail
        }
    }
    
    // MARK: - Private
    
    private func fetchRecentImages() {
        getState {
            // check if not already loading
            guard $0 != .loading(message: SelectImageViewModel.Constants.loadingMessage) else { return }
            // set state to loading
            self.setState { $0 = .loading(message: SelectImageViewModel.Constants.loadingMessage) }
            // get recent images
            self.flickrService.getRecentImages { response in
                switch response {
                case .success(recentImages: let fetchedImages):
                    self.images = fetchedImages
                    self.setState { $0 = fetchedImages.isEmpty ? .noResults : .successfullyFetched(images: fetchedImages) }
                case .failure(error: let error):
                    self.setState { $0 = .apiError(error: error.localizedDescription) }
                }
            }
        }
    }
    
    private func getThumbnail(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        let placeHolderImage = UIImage.Images.placeholder
        
        guard !images.isEmpty else {
            completion(placeHolderImage)
            return
        }
        
        let image = images[indexPath.row]
        var thumbnailImage: UIImage? {
            get {
                return thumbnails[image.id]
            }
            set {
                thumbnails[image.id] = newValue
            }
        }
        
        // check if not already cached
        guard thumbnailImage == nil else {
            // else return cached image
            completion(thumbnailImage)
            return
        }
        
        guard let thumbnailUrl = URL(string: image.thumbnailUrl) else {
            completion(placeHolderImage)
            return
        }
        
        imageService.getImage(from: thumbnailUrl) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(image: let image):
                    thumbnailImage = image
                case .failure(error: _):
                    thumbnailImage = placeHolderImage
                }
                completion(thumbnailImage)
            }
        }
    }
    
}

extension SelectImageViewModel {
    
    enum Constants {
        
        static let loadingMessage = "Loading Recent Photos"
        static let noResultsMessage = "No Results!"
        static let welcomeMessage = "Welcome to Flickr Editor!"
        
    }
    
}
