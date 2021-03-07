//
//  UIViewController+Extensions.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit

extension UIViewController {
    
    func attachChildController(_ childVC: UIViewController) {
        self.addChild(childVC)
        self.view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    func detachFromParent() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        self.didMove(toParent: nil)
    }

}
