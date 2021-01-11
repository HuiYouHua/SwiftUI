//
//  EmailCheckingRequest.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/11.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Combine
import Foundation

//当 promise(.success(true)) 被调用时，说明检查通过
struct EmailCheckRequest {
    let email: String
    var publisher: AnyPublisher<Bool, Never> {
        Future<Bool, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if self.email.lowercased() == "huayoyu@qq.com" {
                    promise(.success(false))
                } else {
                    promise(.success(true))
                }
            }
        }.receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
