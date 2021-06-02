//
//  RequestToken.swift
//  AuxBox
//
//  Created by Ivan Teo on 6/5/21.
//

import Foundation
class RequestToken {
    private weak var task: URLSessionDataTask?

    init(task: URLSessionDataTask) {
        self.task = task
    }

    func cancel() {
        task?.cancel()
    }
}
