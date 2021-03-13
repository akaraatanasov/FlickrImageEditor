//
//  SelectImageCell.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 12.03.21.
//

import UIKit
import ReusableLoadingIndicator

class SelectImageCell: UITableViewCell {

    // MARK: - Subviews
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    private var loadingIndicator: PlainLoadingIndicator?
    
    // MARK: - Setters
    
    var imageTitle: String? {
        didSet {
            if let title = imageTitle, !title.isEmpty {
                titleLabel?.text = title
            } else {
                titleLabel?.text = "No title"
            }
        }
    }
    
    var imageThumbnail: UIImage? {
        didSet {
            thumbnailImageView?.image = imageThumbnail
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadingIndicator = PlainLoadingIndicator(centeredIn: thumbnailImageView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Public
    
    func startLoading() {
        loadingIndicator?.show()
    }
    
    func stopLoading() {
        loadingIndicator?.hide()
    }
    
}
