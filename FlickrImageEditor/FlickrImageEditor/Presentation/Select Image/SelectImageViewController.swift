//
//  SelectImageViewController.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit
import ReusableLoadingIndicator

class SelectImageViewController: ViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - View Model
    
    private let viewModel: SelectImageViewModel
    
    // MARK: - Init
    
    internal init(viewModel: SelectImageViewModel) {
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

    override func setupSubscriptions() {
        viewModel.statePublisher
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .initial:
                    self.tableView.setEmptyMessage(SelectImageViewModel.Constants.welcomeMessage)
                case .loading(message: let message):
                    LoadingIndicator.show(with: message)
                    self.tableView.restore()
                case .successfullyFetched(images: _):
                    LoadingIndicator.hide()
                    self.tableView.reloadData()
                case .noResults:
                    LoadingIndicator.hide()
                    self.tableView.setEmptyMessage(SelectImageViewModel.Constants.noResultsMessage)
                case .apiError(error: let error):
                    LoadingIndicator.hide()
                    self.tableView.setEmptyMessage(error)
                }
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Private
    
    private func setupView() {
        // setup title
        title = SelectImageViewController.Constants.titleText
        // setup refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefreshButton))
        // setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.selectImageCell, bundle: .main), forCellReuseIdentifier: Constants.selectImageCell)
    }
    
    // MARK: - Actions
    
    @objc private func didTapRefreshButton() {
        viewModel.refreshButtonTapped()
    }

}

extension SelectImageViewController {
    
    enum Constants {
        
        static let titleText = "Select Image"
        static let selectImageCell = "SelectImageCell"
        static let cellHeight: CGFloat = 50.0
        
    }
    
}

// MARK: - Table View Delegate

extension SelectImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.imageSelected(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - Table View Data Source

extension SelectImageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imagesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectImageViewController.Constants.selectImageCell, for: indexPath) as! SelectImageCell
        viewModel.configure(cell, for: indexPath)
        return cell
    }
    
}
