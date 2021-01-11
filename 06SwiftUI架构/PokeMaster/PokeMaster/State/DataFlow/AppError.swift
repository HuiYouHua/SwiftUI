//
//  AppError.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation

//除了 Error 外，我们还顺便让 AppError 遵守了 Identifiable 协议。对于 LoginRequest 本身来说，Identifiable 并不是必须的。但我们在接下来的错误 处理一节中会需要用到 Identifiable。
enum AppError: Error, Identifiable {
    //在这里，为了简化，我们使用了 localizedDescription 作为 id。实际中更推荐 为每个错误定义自定义 error code，并使用这个唯一不变的数字作为 id。
    var id: String { localizedDescription }

    case passwordWrong
}

extension AppError: LocalizedError {
    ///localizedDescription 是 LocalizedError 协议的一部分。通过为错误添加本地 化描述，我们可以显示对用户友好的错误信息。
    var localizedDescription: String {
        switch self {
        case .passwordWrong: return "密码错误"
        }
    }
}
