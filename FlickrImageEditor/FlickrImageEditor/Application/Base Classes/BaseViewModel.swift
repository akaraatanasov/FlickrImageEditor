//
//  BaseViewModel.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

/// BaseViewModel  & ViewModel heavily inspired by Cyanic
/// Rewritten in Combine (instead of RxSwift)
/// See https://github.com/feilfeilundfeil/Cyanic/blob/master/Sources/Classes/ViewModel.swift
/// And https://github.com/feilfeilundfeil/Cyanic/blob/master/Sources/Classes/AbstractViewModel.swift

import Foundation
import Combine

internal class BaseViewModel<StateType: State>: NSObject {
    
    // MARK: - Stored Properties
    
    internal var subscriptions = Set<AnyCancellable>()
    internal let stateStore: StateStore<StateType>
    internal let isDebugMode: Bool
    
    // MARK: - Computed Properties
    
    internal var currentStateValue: StateType {
        return self.stateStore.currentStateValue
    }
    
    internal var state: AnyPublisher<StateType, Never> {
        return self.stateStore.state
    }
    
    // MARK: - Init

    internal init(stateStore: StateStore<StateType>, isDebugMode: Bool = false) {
        self.stateStore = stateStore
        self.isDebugMode = isDebugMode
        print("❇️ \(String(describing: type(of: self))) init")
    }

    deinit {
        print("🛑 \(String(describing: type(of: self))) deinit")
    }
}

internal class ViewModel<StateType: State>: BaseViewModel<StateType> {

    // MARK: - Init
    
    override init(stateStore: StateStore<StateType>, isDebugMode: Bool = false) {
        super.init(stateStore: stateStore, isDebugMode: isDebugMode)
    }
    
    init(initialState: StateType = StateType.default as! StateType, isDebugMode: Bool = false) {
        super.init(stateStore: StateStore<StateType>(initialState: initialState), isDebugMode: isDebugMode)
    }
    
    // MARK: - Accessors
    
    internal final func getState(block: @escaping (_ currentState: StateType) -> Void) {
        self.stateStore.getState(with: block)
    }
    
    internal final func setState(with changes: @escaping (_ mutableState: inout StateType) -> Void) {
        switch self.isDebugMode {
            case true:
                self.stateStore.setState(with: { (mutableState: inout StateType) -> Void in
                    let firstState: StateType = mutableState.copy(with: changes)
                    let secondState: StateType = mutableState.copy(with: changes)

                    guard firstState == secondState else {
                        fatalError("Executing block twice produced different states. This shouldn't happen!")
                    }

                    changes(&mutableState)
                })
            case false:
                self.stateStore.setState(with: changes)
        }
    }
    
    // MARK: - Subscribe
    
    internal final func selectSubscribe<T: Equatable>(to keyPath: KeyPath<StateType, T>,
                                                      postInitialValue: Bool,
                                                      onNewValue: @escaping (_ newValue: T) -> Void) {
        var publisher: AnyPublisher<T, Never> = self.stateStore.state
            .map({ (state: StateType) -> T in
                return state[keyPath: keyPath]
            })
            .removeDuplicates()
            .eraseToAnyPublisher()

        if self.isDebugMode {
            publisher = publisher.print("Select Subscribe state change").eraseToAnyPublisher()
        }

        self.resolveInitialValue(for: publisher, postInitialValue: postInitialValue)
            .receive(on: RunLoop.main)
            .sink { (value: T) -> Void in
                onNewValue(value)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Private
    
    private func resolveInitialValue<T>(for publisher: AnyPublisher<T, Never>, postInitialValue: Bool) -> AnyPublisher<T, Never> {
        return postInitialValue ? publisher : publisher.dropFirst().eraseToAnyPublisher()
    }

}
