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
    
    private let ciContext: CIContext
    
    // MARK: - State
    
    var statePublisher: AnyPublisher<EditImageState, Never> {
        return state.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    
    var availableFilters: [ImageFilter] {
        return ImageFilter.allCases
    }
    
    // MARK: - Init
    
    init(imageService: ImageService, flickrImage: FlickrImage, thumbnail: UIImage? = nil) {
        self.ciContext = CIContext(options: nil)
        self.imageService = imageService
        
        let thumbnailImage = thumbnail ?? UIImage()
        let initialState = EditImageState(imageMetadata: flickrImage, beginImage: thumbnailImage, displayImage: thumbnailImage)
        super.init(stateStore: StateStore<EditImageState>(initialState: initialState))
    }
    
    // MARK: - Actions
    
    func viewLoaded() {
        fetchFullSizeImage()
    }
    
    func shareButtonTapped(from sender: Any) {
        getState { self.didShareImage?($0.displayImage, sender) }
    }
    
    func setFilter(value: Float) {
        self.processSelectedFilter(with: value)
    }
    
    func changeFilter(toFilterWith title: String) {
        if let filter = ImageFilter(rawValue: title) {
            setState {
                $0.selectedFilter = filter        // change filter
                $0.displayImage = $0.beginImage   // reset displayImage
            }
        }
    }
    
    func applyFilter() {
        setState { $0.beginImage = $0.displayImage }
        // show loading indicator success
    }
    
    // MARK: - Private
    
    private func processSelectedFilter(with value: Float) {
        getState { state in
            let currentFilter = state.selectedFilter.ciFilter
            currentFilter.setValue(CIImage(image: state.beginImage), forKey: kCIInputImageKey)
            
            let inputKeys = currentFilter.inputKeys
            if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(value, forKey: kCIInputIntensityKey) }
            if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(value * 100, forKey: kCIInputRadiusKey) }
            if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(value * 10, forKey: kCIInputScaleKey) }
            if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: state.displayImage.size.width / 2,
                                                                                       y: state.displayImage.size.height / 2), forKey: kCIInputCenterKey) }
            guard let output = currentFilter.outputImage,
                  let cgImage = self.ciContext.createCGImage(output, from: output.extent) else { return }
            let processedImage = UIImage(cgImage: cgImage)
            
            self.setState { $0.displayImage = processedImage }
        }
    }
    
    private func fetchFullSizeImage() {
        setState { $0.isLoading = true } // start loading indicator
        
        getState {
            // get image
            self.imageService.getImage(from: URL(string: $0.imageMetadata.fullImageUrl)!) { response in
                self.setState { $0.isLoading = false } // stop loading indicator
                
                switch response {
                case .success(image: let image):
                    self.setState {
                        $0.beginImage = image
                        $0.displayImage = image
                    }
                case .failure(error: let error):
                    let errorMessage = error.description
                    self.didFailToFetchImage?(errorMessage)
                }
            }
        }
    }
    
}
