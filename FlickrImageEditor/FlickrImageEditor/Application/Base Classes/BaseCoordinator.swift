//
//  BaseCoordinator.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

import UIKit
import Combine

internal class Coordinator: Equatable {
    
    // MARK: - Properties
    
    internal var subscriptions: Set<AnyCancellable>
    
    private(set) var coordinators: [Coordinator]
    
    internal let rootViewController: UIViewController
    
    internal var onEnd: (() -> Void)?
    
    // MARK: - Init
    
    internal init(rootViewController: UIViewController) {
        self.subscriptions = Set<AnyCancellable>()
        self.coordinators = []
        self.rootViewController = rootViewController
    }
    
    // MARK: - Open Methods
    
    open func push(childCoordinator: Coordinator) {
        coordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    @discardableResult
    open func pop(childCoordinator: Coordinator) -> Coordinator? {
        if let index = coordinators.firstIndex(of: childCoordinator) {
            return coordinators.remove(at: index)
        } else {
            return nil
        }
    }
    
    open func start() { }
    
    // MARK: - Equatable
    
    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs.rootViewController == rhs.rootViewController && lhs.coordinators == rhs.coordinators
    }
}
