//
//  EditImageViewController.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

import UIKit

class EditImageViewController: ViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - View Model
    
    private let viewModel: EditImageViewModel
    
    // MARK: - Init
    
    internal init(viewModel: EditImageViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.viewLoaded()
    }

    override func setupSubscriptions() {
        // setup loading subscription
//        viewModel.statePublisher
//            .map { Bool($0.isLoading) }
//            .assign(to: \.isLoading, on: loadingIndicator)
//            .store(in: &subscriptions)
        
        // setup title label subscription
        viewModel.statePublisher
            .map { String($0.title) }
            .removeDuplicates()
            .sink { [weak self] newTitle in
                self?.titleLabel.text = newTitle
            }
            .store(in: &subscriptions)
        
        // setup image view subscription
        viewModel.selectSubscribe(to: \.image, postInitialValue: true) { [weak self] newImage in
            guard let self = self else { return }
            UIView.transition(with: self.imageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = newImage },
                              completion: nil)
        }
    }
    
    // MARK: - Private
    
    private func setupView() {
        // setup title
        title = "Edit Image"
        // setup refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton(sender:)))
    }
    
    
    // MARK: - Actions
    
    @objc private func didTapShareButton(sender: UIBarButtonItem) {
        viewModel.shareButtonTapped(from: sender)
    }
    
    // TODO: - Add editing action

}
