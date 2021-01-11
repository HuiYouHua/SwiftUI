//
//  AppAction.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation

//因为 settingsBinding 的存在，AppState.Settings 中的 accountBehavior，email， password 这些属性已经和 UI 联动了，现在我们来处理按下登录按钮时的行为。按照我们的原则，UI 不能直接改变 AppState，而需要通过发送 Action 并被 Reducer 处理。
enum AppAction {
    case login(email: String, password: String)
    //异步操作的第二个关键时间点是操作结束，希望使用得到的结果更新 UI 时。在我们 的例子中，这对应着 LoginAppCommand 里 receiveCompletion 和 receiveValue 两个回调。和 View 中不能直接更改 State，而是使用 Action 的规则一样，在 Command 里我们也会向 Store 发送一个 Action 来修改状态。在 AppAction 里，新 加一个 enum 成员:
    case accountBehaviorDone(result: Result<User, AppError>)
    //注销
    case logout
}
