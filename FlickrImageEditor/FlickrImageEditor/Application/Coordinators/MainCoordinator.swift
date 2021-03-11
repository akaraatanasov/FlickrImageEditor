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
        print("✅ Started Select Image Flow")
        // init all select image components
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
        // init all edit image components
        let editImageViewModel = EditImageViewModel(imageService: imageService, flickrImage: image, thumbnail: thumbnail)
        let editImageViewController = EditImageViewController(viewModel: editImageViewModel)
        
        // push the view controller
        navigationController.pushViewController(editImageViewController, animated: true)
        
        // setup navigation actions
        editImageViewModel.didShareImage = { [unowned self, unowned navigationController] image, sender in
            showShareSheet(from: sender, using: image, in: navigationController)
        }
        
        editImageViewModel.didFailToFetchImage = { [unowned self, unowned navigationController] errorMessage in
            showErrorAlert(with: errorMessage, in: navigationController)
        }
        
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(with message: String, in navigationController: UINavigationController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            navigationController.present(alert, animated: true)
        }
    }
    
    private func showShareSheet(from sender: Any, using image: UIImage, in navigationController: UINavigationController) {
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        DispatchQueue.main.async {
            activityViewController.popoverPresentationController?.sourceView = sender as? UIView
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.postToFacebook ]
            navigationController.present(activityViewController, animated: true)
        }
    }
    
}
