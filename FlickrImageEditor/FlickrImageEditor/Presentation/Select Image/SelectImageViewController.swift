//
//  SelectImageViewController.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit

class SelectImageViewController: ViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - View State
    
    private var images: [FlickrImage] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - View Model
    
    private let viewModel: SelectImageViewModel
    
    // MARK: - Init
    
    internal init(viewModel: SelectImageViewModel) {
        self.images = []
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
        viewModel.statePublisher
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .initial:
                    self.tableView.setEmptyMessage("Welcome to Flickr Editor!")
                case .loading(message: let message):
                    self.images = []
                    self.tableView.setEmptyMessage(message) // TODO: - Replace this with start loading indicator call
                case .successfullyFetched(images: let images):
                    // TODO: - Add stop loading indicator call
                    self.images = images
                    self.tableView.restore()
                case .noResults:
                    // TODO: - Add stop loading indicator call
                    self.tableView.setEmptyMessage("No Results!")
                case .apiError(error: let error):
                    // TODO: - Add stop loading indicator call
                    self.tableView.setEmptyMessage(error)
                }
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Private
    
    private func setupView() {
        // setup title
        title = "Select Image"
        // setup refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefreshButton))
        // setup table view
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // MARK: - Actions
    
    @objc private func didTapRefreshButton() {
        viewModel.refreshButtonTapped()
    }

}

// MARK: - Table View Delegate

extension SelectImageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.imageSelected(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table View Data Source

extension SelectImageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = images[indexPath.row].title
        return cell
    }
    
}
