//
//  MainCoordinator.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import Combine
import UIKit

final class MainCoordinator: Coordinator {
    
    // MARK: - Dependencies
    
//    private let flickrService: FlickrService // manages flickr requests
    
    // MARK: - Init
    
    override init(rootViewController: UIViewController) {
//        self.flickrService = FlickrService()
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
        let selectImageViewModel = SelectImageViewModel()
        let selectImageViewController = SelectImageViewController(viewModel: selectImageViewModel)
        let selectImageNavigationController = UINavigationController(rootViewController: selectImageViewController)
        
        // attach the navigation controller
        rootViewController.attachChildController(selectImageNavigationController)
        
        // setup view constraints to edges
        
        // setup navigation actions
//        selectImageViewModel.didSelectImage = { [unowned self, unowned selectImageNavigationController] image in
//            self.startEditImageFlow(with: image, navigationController: selectImageNavigationController)
//        }
    }
    
    // MARK: - Edit Image Flow
    
    private func startEditImageFlow(with image: UIImage, navigationController: UINavigationController) {
        print("🌉 Started Edit Image Flow")
        // TODO: - Add Edit Image Components
    }
    
}
