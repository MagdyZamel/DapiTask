//
//  AsyncOperation.swift
//  DapiTask
//
//  Created by MSZ on 15/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation
/// Asynchronous operations allow executing long-running tasks without having to block the calling thread until the execution completes
/// - important: The AsyncOperation should be executed on the custom queue not the **Main**, so don't run it on main
class AsyncOperation: Operation {
    enum State: String {
        case ready, executing, finished
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    private var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    var hasCancelledDependencies: Bool {
        // Return true if this operation has any dependency (parent) operation that is cancelled
        return dependencies.contains(where: {$0.isCancelled})
    }

    override final public func start() {
        // If run Into Main method it will be canceled
        if Thread.isMainThread {
            cancel()
            return
        }
        // If any dependency (parent operation) is cancelled, we should also cancel this operation
        if hasCancelledDependencies {
            set(state: .finished)
            return
        }
        if isCancelled {
            set(state: .finished)
            return
        }
        set(state: .executing)
        main()
    }

    func set(state: State) {
        self.state = state
    }
}
