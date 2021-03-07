//
//  SelectImageViewModel.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit
import Combine

class SelectImageViewModel: ViewModel<SelectImageState> {
    
    // MARK: - Properties
    
//    private let flickrService: FlickrService // manages flickr requests
    
    var statePublisher: AnyPublisher<SelectImageState, Never> {
        return state.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    
    func viewLoaded() {
        fetchRecentPhotos()
    }
    
    func refreshButtonTapped() {
        fetchRecentPhotos()
    }
    
    func imageSelected(at indexPath: IndexPath) {
        print("- indexPath: \(indexPath)")
    }
    
    // MARK: - Public
    
    public func getImage(for indexPath: IndexPath) {
        
    }
    
    // MARK: - Private
    
    private func fetchRecentPhotos() {        
        // set state to loading
        setState { $0 = .loading(message: "Now Loading Recent Photos") }
        
        // simulating network request
        DispatchQueue.global().asyncAfter(deadline:  DispatchTime.now() + .seconds(2), qos: .background) {
            let fetchedImages = [FlickrImage(id: "1", title: "Hello 1", thumbnailUrl: "", fullImageUrl: ""),
                                 FlickrImage(id: "2", title: "Hello 2", thumbnailUrl: "", fullImageUrl: ""),
                                 FlickrImage(id: "3", title: "Hello 3", thumbnailUrl: "", fullImageUrl: ""),
                                 FlickrImage(id: "4", title: "Hello 4", thumbnailUrl: "", fullImageUrl: ""),
                                 FlickrImage(id: "5", title: "Hello 5", thumbnailUrl: "", fullImageUrl: ""),
                                 FlickrImage(id: "6", title: "Hello 6", thumbnailUrl: "", fullImageUrl: "")]
            self.setState { mutableState in
                switch Int.random(in: 1...3) {
                case 1: mutableState = .successfullyFetched(images: fetchedImages)
                case 2: mutableState = .noResults
                default: mutableState = .apiError(error: "API Error: Couldn't fetch recent photos!")
                }
            }
        }
    }
    
}
