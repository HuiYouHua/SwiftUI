//
//  SettingView.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

class Settings: ObservableObject {

    enum AccountBehavior: CaseIterable {
        case register, login
    }

    enum Sorting: CaseIterable {
        case id, name, color, favorite
    }

    @Published var accountBehavior = AccountBehavior.login
    @Published var email = ""
    @Published var password = ""
    @Published var verifyPassword = ""

    @Published var showEnglishName = true
    @Published var sorting = Sorting.id
    @Published var showFavoriteOnly = false
}

struct SettingView: View {
    @ObservedObject var settings = Settings()
    var body: some View {
        Form {
            accountSection
            optionSection
            actionSection
        }
    }

    var accountSection: some View {
        Section(header: Text("账户")) {
            //对于 “从多个值中选择一个” 的情景，Picker 类型是最合适的。我们需要提供 一个 Binding 作为当前被选择的对象，并在 Picker 的构建中指明可能的选项。
            Picker(selection: $settings.accountBehavior, label: Text("")) {
                ForEach(Settings.AccountBehavior.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            //Picker 提供了多种可选择的样式，在 Form 中它默认是以 Push 导航方式在新 画面中询问用户的选择。这里我们使用 SegmentedPickerStyle 来得到分段式 的选项 UI。
            .pickerStyle(SegmentedPickerStyle())
            //TextField 和 SecureField 分别对应普通的文本输入框和密码输入框 (输入显 示为黑圆点)。
            TextField("电子邮箱", text: $settings.email)
            SecureField("密码", text: $settings.password)
            //确认密码的输入框只在注册时需要显示。
            if settings.accountBehavior == .register {
                SecureField("确认密码", text: $settings.verifyPassword)
            }
            Button(settings.accountBehavior.text) {
                print("登录/注册")
            }
        }
    }

    var optionSection: some View {
        Section(header: Text("选项")) {
            Toggle(isOn: $settings.showEnglishName) {
                Text("显示英文名")
            }
            Picker(selection: $settings.sorting, label: Text("排序方式")) {
                ForEach(Settings.Sorting.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            Toggle(isOn: $settings.showFavoriteOnly) {
                Text("只显示收藏")
            }
        }
    }

    var actionSection: some View {
        Section {
            Button(action: {
                print("清空缓存")
            }) {
                Text("清空缓存").foregroundColor(.red)
            }
        }
    }
}

extension Settings.Sorting {
    var text: String {
        switch self {
        case .id: return "ID"
        case .name: return "名字"
        case .color: return "颜色"
        case .favorite: return "最爱"
        }
    }
}

extension Settings.AccountBehavior {
    var text: String {
        switch self {
        case .register: return "注册"
        case .login: return "登录"
        }
    }
}
