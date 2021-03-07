//
//  UITableView+Extensions.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit

extension UITableView {

    func setEmptyMessage(_ message: String, backgroundColor: UIColor = .white, textColor: UIColor = .black) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.backgroundView?.backgroundColor = backgroundColor
        self.separatorStyle = .none
        self.reloadData()
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
        self.reloadData()
    }
    
}
