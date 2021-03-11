//
//  EditImageState.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

import UIKit

enum ImageFilter: String, CaseIterable {
    case blur = "Blur"
    case sepia = "Sepia"
    case vignette = "Vignette"
    case sharpen = "Sharpen"
    case lines = "Lines"
    case crystallize = "Crystallize"
    case bumpDistortion = "Bump Distort"
    
    var ciFilter: CIFilter {
        switch self {
        case .blur: return CIFilter(name: "CIGaussianBlur")!
        case .sepia: return CIFilter(name: "CISepiaTone")!
        case .vignette: return CIFilter(name: "CIVignette")!
        case .sharpen: return CIFilter(name: "CISharpenLuminance")!
        case .lines: return CIFilter(name: "CILineOverlay")!
        case .crystallize: return CIFilter(name: "CICrystallize")!
        case .bumpDistortion: return CIFilter(name: "CIBumpDistortion")!
        }
    }
}

struct EditImageState: State {
    static var `default`: EditImageState {
        return EditImageState(imageMetadata: FlickrImage(id: "",
                                                         title: "",
                                                         thumbnailUrl: "",
                                                         fullImageUrl: ""),
                              beginImage: UIImage(),
                              displayImage: UIImage())
    }
    
    // MARK: - Properties
    
    var isLoading: Bool = false
    var imageMetadata: FlickrImage
    var beginImage: UIImage
    var displayImage: UIImage
    var selectedFilter: ImageFilter = .blur
}
