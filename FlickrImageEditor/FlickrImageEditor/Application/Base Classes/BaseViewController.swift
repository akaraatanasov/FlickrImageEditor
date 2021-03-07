//
//  BaseViewController.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit
import Combine

internal class ViewController: UIViewController {
    
    // MARK: - Stored Properties
    
    internal var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Overrides
    
    override func loadView() {
        super.loadView()
        
        let nibName = String(describing: type(of: self))
        guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
            return
        }
        
        view = Bundle.main.loadNibNamed(nibName, owner: self)?.first as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscriptions()
    }
    
    // MARK: - Subscriptions
    
    open func setupSubscriptions() { }
    
}
