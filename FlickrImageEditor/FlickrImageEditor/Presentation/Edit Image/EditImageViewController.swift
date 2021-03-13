//
//  EditImageViewController.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

import UIKit
import ReusableLoadingIndicator

class EditImageViewController: ViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var filterNameLabel: UILabel!
    @IBOutlet private weak var filterIntensitySlider: UISlider!
    @IBOutlet private weak var changeFilterButton: UIButton!
    @IBOutlet private weak var applyFilterButton: UIButton!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if LoadingIndicator.isRunning {
            LoadingIndicator.hide()
        }
    }

    // This method presents the 3 different ways we can subscribe to state changes:
    override func setupSubscriptions() {
        // setup title label subscription (1. With Combine's assign operator)
        viewModel.statePublisher
            .map { String($0.imageMetadata.title) }
            .removeDuplicates()
            .assign(to: \.text, on: titleLabel)
            .store(in: &subscriptions)
        
        // setup filter name label subscription (2. With Combine's sink operator)
        viewModel.statePublisher
            .map { String($0.selectedFilter.rawValue) }
            .removeDuplicates()
            .sink { [weak self] newFilterName in
                self?.filterNameLabel.text = newFilterName
            }
            .store(in: &subscriptions)
        
        // setup image view subscription (3. With view model's subscribe to keypath method)
        viewModel.selectSubscribe(to: \.displayImage, postInitialValue: true) { [weak self] newImage in
            self?.imageView.image = newImage
        }
        
        // setup loading subscription
        viewModel.selectSubscribe(to: \.isLoading, postInitialValue: false) { isLoading in
            if isLoading {
                LoadingIndicator.show(with: EditImageViewModel.Constants.loadingMessage)
            } else {
                LoadingIndicator.hide()
            }
        }
    }
    
    // MARK: - Private
    
    private func setupView() {
        // setup title
        title = EditImageViewController.Constants.titleText
        // setup refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton(sender:)))
        // setup filter name label
        filterNameLabel.isUserInteractionEnabled = true
        filterNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeFilterButton)))
        // setup filter intensity slider
        filterIntensitySlider.tintColor = .gray
        // setup change filter button
        changeFilterButton.setTitle("Change Filter", for: .normal)
        changeFilterButton.setTitleColor(.white, for: .normal)
        changeFilterButton.backgroundColor = .gray
        changeFilterButton.layer.cornerRadius = 5.0
        changeFilterButton.clipsToBounds = false
        // setup apply filter button
        applyFilterButton.setTitle("Apply", for: .normal)
        applyFilterButton.setTitleColor(.white, for: .normal)
        applyFilterButton.backgroundColor = .gray
        applyFilterButton.layer.cornerRadius = 5.0
        applyFilterButton.clipsToBounds = false
    }
    
    
    // MARK: - Actions
    
    @objc private func didTapShareButton(sender: UIBarButtonItem) {
        viewModel.shareButtonTapped(from: sender)
    }
    
    @IBAction private func didChangeSlider(_ sender: Any) {
        viewModel.setFilter(value: filterIntensitySlider.value)
    }
    
    @IBAction private func didTapChangeFilterButton(sender: Any) {
        func setFilter(action: UIAlertAction) {
            guard let title = action.title else { return }
            viewModel.changeFilter(toFilterWith: title)
            resetSlider()
        }
        
        let actionSheet = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        for filter in viewModel.availableFilters {
            actionSheet.addAction(UIAlertAction(title: filter.rawValue, style: .default, handler: setFilter))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @IBAction private func didTapApplyButton(sender: Any) {
        viewModel.applyFilter()
        resetSlider()
    }
    
    // MARK: - Private
    
    private func resetSlider() {
        UIView.animate(withDuration: 0.2, animations: {
            self.filterIntensitySlider.setValue(0.01, animated:true)
        })
    }
    
}

extension EditImageViewController {
    
    enum Constants {
        
        static let titleText = "Edit Image"
        
    }
    
}
