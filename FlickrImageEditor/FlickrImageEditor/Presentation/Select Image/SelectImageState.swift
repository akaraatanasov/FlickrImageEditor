//
//  SelectImageState.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import Foundation

enum SelectImageState: State {
    static var `default`: SelectImageState {
        return .initial
    }
    
    case initial
    case loading(message: String)
    case successfullyFetched(images: [FlickrImage])
    case noResults
    case apiError(error: String)
}
