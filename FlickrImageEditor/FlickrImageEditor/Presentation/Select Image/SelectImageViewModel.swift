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
    private var thumbnails: [String: UIImage?]
    
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
        let thumbnail = thumbnails[selectedImage.id] as? UIImage
        didSelectImage?(selectedImage, thumbnail)
    }
    
    // MARK: - Private
    
    private func fetchRecentImages() {
        self.images = []
        // set state to loading
        setState { $0 = .loading(message: "Now Loading Recent Photos") }
        // get recent images
        flickrService.getRecentImages { response in
            switch response {
            case .success(recentImages: let fetchedImages):
                self.images = fetchedImages
                self.setState { $0 = fetchedImages.isEmpty ? .noResults : .successfullyFetched(images: fetchedImages) }
            case .failure(error: let error):
                self.setState { $0 = .apiError(error: error.localizedDescription) }
            }
        }
    }
    
    private func getThumbnail(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        let image = images[indexPath.row]
        let imageId = image.id
        let thumbnail = thumbnails[imageId] as? UIImage
        guard thumbnail == nil else {
            completion(thumbnail)
            return
        }
        
        imageService.getImage(from: URL(string: image.thumbnailUrl)!) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(image: let image):
                    self.thumbnails[imageId] = image
                    completion(image)
                case .failure(error: _):
                    completion(nil)
                }
            }
        }
    }
    
}

// MARK: - Table View Data Source

extension SelectImageViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = images[indexPath.row].title
//        cell.loadingIndicator.start()
        getThumbnail(for: indexPath) { thumbnail in
//            cell.loadingIndicator.stop()
            cell.imageView?.image = thumbnail
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        return cell
    }
    
}
