//
//  MainCoordinator.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    // MARK: - Dependencies
    
    private let flickrService: FlickrService // manages flickr requests
    
    private let imageService: ImageService // manages image requests
    
    // MARK: - Init
    
    override init(rootViewController: UIViewController) {
        self.flickrService = FlickrService()
        self.imageService = ImageService()
        super.init(rootViewController: rootViewController)
        print("❇️ \(String(describing: type(of: self))) init")
    }
    
    deinit {
        print("🛑 \(String(describing: type(of: self))) deinit")
    }
    
    // MARK: - Coordinator Start
    
    override func start() {
        startSelectImageFlow()
    }
    
    // MARK: - Select Image Flow
    
    private func startSelectImageFlow() {
        // init all select image components
        print("✅ Started Select Image Flow")
        let selectImageViewModel = SelectImageViewModel(flickrService: flickrService, imageService: imageService)
        let selectImageViewController = SelectImageViewController(viewModel: selectImageViewModel)
        let selectImageNavigationController = UINavigationController(rootViewController: selectImageViewController)
        
        // attach the navigation controller
        rootViewController.attachChildController(selectImageNavigationController)
        
        // setup navigation actions
        selectImageViewModel.didSelectImage = { [unowned self, unowned selectImageNavigationController] image, thumbnail in
            self.startEditImageFlow(with: image, and: thumbnail, in: selectImageNavigationController)
        }
    }
    
    // MARK: - Edit Image Flow
    
    private func startEditImageFlow(with image: FlickrImage, and thumbnail: UIImage? = nil, in navigationController: UINavigationController) {
        print("🌉 Started Edit Image Flow")
        // TODO: - Add Edit Image Components
    }
    
}
