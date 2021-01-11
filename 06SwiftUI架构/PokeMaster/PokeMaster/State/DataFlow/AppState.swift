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
        
        
        
        var accountBehavior = AccountBehavior.login
        var email = ""
        var password = ""
        var verifyPassword = ""
        
        @UserDefaultsBoolStorage(initialValue: false, key: "showEnglishName")
        var showEnglishName: Bool
        @UserDefaultsStringStorage(initialValue: Sorting.id, key: "sorting")
        var sorting: Sorting
        @UserDefaultsBoolStorage(initialValue: false, key: "showFavoriteOnly")
        var showFavoriteOnly: Bool
        
        /**
         
         //loginUser 在初始化时通过 loadJSON 从磁盘上的 “user.json” 文件中进行读 取。这让我们的用户信息可以在 app 重启后保持。
         var loginUser: User? = try? FileHelper.loadJSON(from: .documentDirectory, fileName: "user.json") {
         didSet {
         if let value = loginUser {
         //当设置 loginUser 时，如果值存在，那么将它序列化并写到文件中。
         try? FileHelper.writeJSON(value, to: .documentDirectory, fileName: "user.json")
         } else {
         //如果我们将 loginUser 设为 nil 时，作为纯副作用，我们将 user.json 删除。
         try? FileHelper.delete(from: .documentDirectory, fileName: "user.json")
         }
         }
         }
         
         在介绍 SwiftUI 数据状态和绑定的时候，我们提到过 @propertyWrapper。它可以用 来包装某个属性，并在 getter 和 setter 被调用时赋予其额外的逻辑。在 SwiftUI 中， 类似 @State，@ObservedObject 实际上都是 @propertyWrapper 的具体应用。在 这里，从文件中读取数据和将值保存到文件中的操作，恰好是 @propertyWrapper 的一个绝佳应用场景。
         
         */
        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: User?
        
        var loginReuqesting = false
        var loginError: AppError?
    }
    
    
}

enum Sorting: String, CaseIterable {
    case id = "ID"
    case name = "名字"
    case color = "颜色"
    case favorite = "最爱"
    
    //    var text: String {
    //        switch self {
    //        case .id: return "ID"
    //        case .name: return "名字"
    //        case .color: return "颜色"
    //        case .favorite: return "最爱"
    //        }
    //    }
}
