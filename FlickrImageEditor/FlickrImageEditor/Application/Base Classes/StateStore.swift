//
//  StateStore.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 7.03.21.
//

/// StateStore heavily inspired by Cyanic
/// Rewritten in Combine (instead of RxSwift)
/// See https://github.com/feilfeilundfeil/Cyanic/blob/master/Sources/Classes/StateStore.swift


import Foundation
import Combine

internal protocol Copyable {}

internal extension Copyable {
    func copy(with changes: (_ mutableSelf: inout Self) -> Void) -> Self {
        var mutableSelf: Self = self
        changes(&mutableSelf)
        return mutableSelf
    }
}

internal protocol State: Equatable, Copyable {
    associatedtype StateType
    static var `default`: StateType { get }
}

internal class StateStore<StateType: State> {
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Execution Properties
    
    private let lock: NSRecursiveLock = NSRecursiveLock()
    
    private let closureQueue: ClosureQueue<StateType> = ClosureQueue<StateType>()
    
    private let executionSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - State Properties
    
    private let stateSubject: CurrentValueSubject<StateType, Never>

    internal var currentStateValue: StateType {
        return self.stateSubject.value
    }

    internal var state: AnyPublisher<StateType, Never> {
        return self.stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Init
    
    internal init(initialState: StateType) {
        self.stateSubject = CurrentValueSubject(initialState)
        // set up execution
        let id: String = UUID().uuidString
        let queue: DispatchQueue = DispatchQueue(label: id, qos: .userInitiated)
        self.executionSubject
            .receive(on: queue)
            .debounce(for: .milliseconds(1), scheduler: queue)
            .sink { [weak self] in
                self?.resolveClosureQueue()
            }
            .store(in: &subscriptions)
        
        print("❇️ \(String(describing: type(of: self))) init")
    }
    
    deinit {
        print("🛑 \(String(describing: type(of: self))) deinit")
    }
    
    // MARK: - Accessors
    
    internal func setState(with reducer: @escaping (_ mutableState: inout StateType) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        self.closureQueue.add(reducer: reducer)
        self.executionSubject.send()
    }
    
    internal func getState(with block: @escaping (_ currentState: StateType) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        self.closureQueue.add(block: block)
        self.executionSubject.send()
    }
    
    // MARK: - Private
    
    private func resolveClosureQueue() {
        self.resolveSetStateQueue()
        guard let getBlock = self.closureQueue.dequeueFirstGetStateCallback() else { return }
        getBlock(currentStateValue)
        self.resolveClosureQueue()
    }
    
    private func resolveSetStateQueue() {
        let reducers: [(inout StateType) -> Void] = self.closureQueue.dequeueAllSetStateClosures()
        guard !reducers.isEmpty else { return }
        let newState: StateType = reducers
            .reduce(into: currentStateValue) { (state: inout StateType, block: (inout StateType) -> Void) -> Void in
                block(&state)
            }
        guard newState != currentStateValue else { return }
        self.stateSubject.send(newState)
    }
    
}

fileprivate class ClosureQueue<State> {

    private let lock: NSRecursiveLock = NSRecursiveLock()

    // MARK: - Queues
    
    internal var setStateQueue: [(inout State) -> Void] = []
    
    internal var getStateQueue: [(State) -> Void] = []

    // MARK: - Add
    
    internal func add(reducer: @escaping (_ mutableState: inout State) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        self.setStateQueue.append(reducer)
    }
    
    internal func add(block: @escaping (_ state: State) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        self.getStateQueue.append(block)
    }

    // MARK: - Dequeue
    
    internal func dequeueAllSetStateClosures() -> [(inout State) -> Void] {
        self.lock.lock(); defer { self.lock.unlock() }
        guard !self.setStateQueue.isEmpty else { return [] }
        let callbacks: [(inout State) -> Void] = self.setStateQueue
        self.setStateQueue = []
        return callbacks
    }
    
    internal func dequeueFirstGetStateCallback() -> ((State) -> Void)? {
        self.lock.lock(); defer { self.lock.unlock() }
        guard !self.getStateQueue.isEmpty else { return nil }
        return self.getStateQueue.removeFirst()
    }

}
