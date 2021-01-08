//
//  AppState.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct AppState {
    //在这里，我们选择按照页面的方式把状态组织到各自的名称下。注意，这里的 Settings 指的是接下来要定义的 AppState.Settings，而不是我们已经定义在 SettingView 中的全局的 Settings。Swift 在局部 (AppState) 中存在同名类型 的时候，会优先使用局部的类型。
    var settings = Settings()
}

extension AppState {
    //在 AppState 中定义 Settings，并把原来的全局 Settings 中的选项相关部分 的模型移动过来。
    struct Settings {
        enum AccountBehavior: CaseIterable {
            case register, login
        }

        enum Sorting: CaseIterable {
            case id, name, color, favorite
        }
        
        var accountBehavior = AccountBehavior.login
        var email = ""
        var password = ""
        var verifyPassword = ""
        
        var showEnglishName = true
        var sorting = Sorting.id
        var showFavoriteOnly = false
        
        var loginUser: User?
        
    }
    
    
}

