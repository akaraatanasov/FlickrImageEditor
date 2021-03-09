//
//  EditImageState.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

import UIKit

struct EditImageState: State {
    static var `default`: EditImageState {
        return EditImageState(title: "", image: UIImage())
    }
    
    // MARK: - Properties
    
    var title: String
    var image: UIImage
    var isLoading: Bool = false
    
}
