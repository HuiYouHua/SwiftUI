//
//  SettingView.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI
import Combine

/**
 传统Redux思想:
 1.Store: Store 就是保存数据的地方，你可以把它看成一个容器。整个应用只能有一个 Store。
 
 2.State: Store对象包含所有数据。如果想得到某个时点的数据，就要对 Store 生成快照。这种时点的数据集合，就叫做 State。通过store.getState()拿到。Store中存储着state
    Redux 规定， 一个 State 对应一个 View。只要 State 相同，View 就相同。你知道 State，就知道 View 是什么样，反之亦然。
 
 3.Action: State 的变化，会导致 View 的变化。但是，用户接触不到 State，只能接触到 View。所以，State 的变化必须是 View 导致的。Action 就是 View 发出的通知，表示 State 应该要发生变化了。
    Action 是一个对象。其中的type属性是必须的，表示 Action 的名称。其他属性可以自由设置
 ```
     const action = {
       type: 'ADD_TODO',
       payload: 'Learn Redux'
     };
    这里我们的action放在枚举的参数里了
 ```
 
 4.Action Creator: View 要发送多少种消息，就会有多少种 Action。如果都手写，会很麻烦。可以定义一个函数来生成 Action，这个函数就叫 Action Creator。
 ```
     const ADD_TODO = '添加 TODO';

     function addTodo(text) {
       return {
         type: ADD_TODO,
         text
       }
     }

     const action = addTodo('Learn Redux');
 ```
 
 5.store.dispatch(): store.dispatch()是 View 发出 Action 的唯一方法。
 
 6.Reducer: Store 收到 Action 以后，必须给出一个新的 State，这样 View 才会发生变化。这种 State 的计算过程就叫做 Reducer。
 Reducer 是一个函数，它接受 Action 和当前 State 作为参数，返回一个新的 State。
 
 7.纯函数: Reducer函数最重要的特征是，它是一个纯函数。也就是说，只要是同样的输入，必定得到同样的输出。
    由于 Reducer 是纯函数，就可以保证同样的State，必定得到同样的 View。但也正因为这一点，Reducer 函数里面不能改变 State，必须返回一个全新的对象

 8.store.subscribe(): Store 允许使用store.subscribe方法设置监听函数，一旦 State 发生变化，就自动执行这个函数。
 
 */


/**
 Swift Redux 的数据流动方式
 1. 将 app 当作一个状态机，状态决定用户界面。
 2. 这些状态都保存在一个 Store 对象中。
 3. View 不能直接操作 State，而只能通过发送 Action 的方式，间接改变存储在 Store 中的 State。
 4. Reducer 接受原有的 State 和发送过来的 Action，生成新的 State。
 5. 用新的 State 替换 Store 中原有的状态，并用新状态来驱动更新界面。
 
 传统 Redux 有两点比较大的限制，在 SwiftUI 中会显得有些水土不服，可能需要一 些改进。
 首先，“只能通过发送 Action 的方式，间接改变存储在 Store 中的 State” 这个要求 太过严格。SwiftUI 有着方便和现成的 Binding 行为，来完成状态和界面的双向绑定。使用这个特性可以大幅简化程序的编写，同时保持数据流的清晰稳定。因此，我们希 望为状态改变设置一个例外:除了通过 Action 外，也可以通过 Binding 来改变状态。
 */
struct SettingView: View {
    
    @EnvironmentObject var store: Store
    var settingBinding: Binding<AppState.Settings> {
        $store.appState.settings
    }
    var settings: AppState.Settings {
        store.appState.settings
    }
    var body: some View {
        Form {
            accountSection
            optionSection
            actionSection
        }
    }

    var accountSection: some View {
        Section(header: Text("账户")) {
            if settings.loginUser == nil {
                Picker(selection: settingBinding.accountBehavior, label: Text("")) {
                    ForEach(AppState.Settings.AccountBehavior.allCases, id: \.self) {
                        Text($0.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                TextField("电子邮箱", text: settingBinding.email)
                SecureField("密码", text: settingBinding.password)
                if settings.accountBehavior == .register {
                    SecureField("确认密码", text: settingBinding.verifyPassword)
                }
                Button(settings.accountBehavior.text) {
                    //最后，在 SettingView 中按下登录按钮时，把刚刚定义的 .login Action 发送给 store
                    self.store.dispatch(.login(email: self.settings.email, password: self.settings.password))
                }
            } else {
                Text(settings.loginUser!.email)
                Button("注销") {
                    print("注销")
                }
            }
            
        }
    }

    var optionSection: some View {
        Section(header: Text("选项")) {
            Toggle(isOn: settingBinding.showEnglishName) {
                Text("显示英文名")
            }
            Picker(selection: settingBinding.sorting, label: Text("排序方式")) {
                ForEach(AppState.Settings.Sorting.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            Toggle(isOn: settingBinding.showFavoriteOnly) {
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

extension AppState.Settings.Sorting {
    var text: String {
        switch self {
        case .id: return "ID"
        case .name: return "名字"
        case .color: return "颜色"
        case .favorite: return "最爱"
        }
    }
}

extension AppState.Settings.AccountBehavior {
    var text: String {
        switch self {
        case .register: return "注册"
        case .login: return "登录"
        }
    }
}

/**
 为什么选择单向数据流
 对于这个事件流周期一个常见的疑问是，为什么我们需要这么麻烦，使用 Action 去 间接地改变状态。难道不能在按钮点击的时候像下面这样把修改模型的逻辑放进来 么?这样岂不是逻辑更加直接和明确?比如:
     ```
     Button(settings.accountBehavior.text) {
     if self.settings.password !" "password" {
     self.store.appState.settings.loginUser = User(
     email: self.settings.email,
            favoritePokemonIDs: []
           )
     } }
     ```
 诚然，这样的做法比走一圈 Action 要直接得多，但是这在三个维度上存在风险。
 1. 首先，将类似密码验证和登录这样的具体逻辑放到 View 中，这让 Model 和 View 形成了高度的耦合。随着我们把越来越多的逻辑放在 View 中，最终也必 然导致 View 的功能和职责越趋复杂。除了定义样式布局之外，它还需要承担 修改 app 状态和组织逻辑的工作，最终出现类似 Massive View Controller 那 样的庞大化问题。
 2. 更重要的是，我们对于 AppState 的修改将分散在 app 各处:对于同一个属性 的修改可能会在不同的地方进行;某些属性的修改可能对另外的一些属性产生 影响;在状态逐渐复杂时，对现有逻辑的修改往往需要在 app 各个 View 代码 之间跳转和来回确认。很快 app 状态的复杂程度和维护难度都将超过人类极 限，这是绝大部分 bug 产生的来源，会导致项目开发难以持续。
 3. 最后，将逻辑代码放在 View 中，导致这部分逻辑难以测试。我们很难去一段 测试代码，来模拟按钮的点击，然后去判断写在 View 的事件里的逻辑是否正 确。但是如果我们把单纯的状态变化逻辑统一放到 Reducer 中，那单元测试 就将轻而易举。通过构建需要的 AppState，我们可以以任意 app 状态作为测 试的起始。而与 UI 视图层行为脱钩的 app 状态，和没有副作用的 reducer 方 法，让我们有机会覆盖所有的使用情况。
 通过 Action 间接改变状态，在短时间和状态很简单 app 中，似乎有点 “得不偿失”。 但是在长期和复杂的情况下，它的优势将非常明显。
 */
