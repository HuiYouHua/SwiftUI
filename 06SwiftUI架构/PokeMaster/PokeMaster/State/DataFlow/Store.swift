//
//  Store.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Combine

//将 Store 声明为 ObservableObject，这样我们就可以在 View 里通过 @ObservedObject 或者 @EnvironmentObject 来访问它了。
class Store: ObservableObject {
    @Published var appState = AppState()
    
    //其次，是可以让 View 调用的用于表示发送了某个 Action 的方法。在这个方法中，我 们将当前 AppState 和收到的 Action 交给 reduce，然后把返回的 state 设置为新的 状态。
    func dispatch(_ action: AppAction) {
        #if DEBUG
        print("[ACTION]: \(action)")
        #endif
        //将当前 AppState 和收到的 Action 交给 reduce
        let result = Store.reduce(state: appState, action: action)
        //把返回的 state 设置为新的 状态
        appState = result
    }
    
    //用来处理某个 AppAction，并 返回新的 AppState 的 Reducer 角色
    //静态的纯函数
    static func reduce(state: AppState, action: AppAction) -> AppState {
        var appState = state
        
        //由于我们选用了 enum 作为 AppAction 的类型，这可以让我们对 action 使用 switch 语句，编译器会帮助我们保证所有的 AppAction 都得到了处理。
        switch action {
        case .login(let email, let password):
            //这里做了一些 “虚假” 的检查，只有密码正确才允许登录。之后，我们会把这 部分替换成异步的更接近于真实情况的登录逻辑。
            if password == "password" {
                //登录成功，设置 appState 中的 loginUser，并返回这个新的 appState
                let user = User(email: email, favoritePokemonIDs: [])
                appState.settings.loginUser = user
            }
        }
        return appState
    }
}


