//
//  LoginRequest.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation
import Combine

struct LoginRequest {
    let email: String
    let password: String
    
    //使用一个 Publisher 来发布登录操作的在未来的可能结果。当登录成功时，可 以得到一个 User 值，否则给出 AppError。我们马上会看到 AppError 的定义。
    var publisher: AnyPublisher<User, AppError> {
        Future { promise in
            //把新建的 Future Publisher 发送到后台队列，并延时 1.5 秒执行。这用来模拟 网络请求的延时状况。
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                if self.password == "password" {
                    let user = User(email: self.email, favoritePokemonIDs: [])
                    promise(.success(user))
                } else {
                    promise(.failure(.passwordWrong))
                }
            }
        }.receive(on: DispatchQueue.main)//因为我们会想用这个 Publisher 的值更新 UI，所以我们指定后续的接收者应 该在主队列接收事件。
        .eraseToAnyPublisher()//我们不关心变形后的 Publisher 的具体类型，所以将它的类型抹掉。
    }
}
