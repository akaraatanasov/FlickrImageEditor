//
//  Publisher+Extensions.swift
//  FlickrImageEditor
//
//  Created by Alexander Karaatanasov on 9.03.21.
//

/// Fixes a retain cycle caused by the Combine framework
/// More info here: https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546/11

import Combine

extension Publisher where Failure == Never {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
       sink { [weak root] in
            root?[keyPath: keyPath] = $0
       }
    }
}
