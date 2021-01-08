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
}
