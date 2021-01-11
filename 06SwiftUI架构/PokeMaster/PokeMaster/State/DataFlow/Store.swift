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
        //因为 reduce 现在返回一个多元组，所以 dispatch(_:) 方法也需要一些更新。除了设 置新的 state 以外，当 AppCommand 存在时，我们需要执行它。修改 dispatch(_:) 的内容:
        let result = Store.reduce(state: appState, action: action)
        //result 的类型不再是 AppState，而是 (AppState, AppCommand?)。对 appState 的设置要用到的是新返回的多元组中的第一个值。
        appState = result.0
        
        if let command = result.1 {
            #if DEBUG
            print("[COMMAND]: \(command)")
            #endif
            //检查如果 AppCommand 存在的话，就调用 execute(in:) 来执行它。和 ACTION 一样，我们也在调试期间把待执行的 COMMAND 打印出来，方便我 们观测发生了什么。
            command.execute(in: self)
        }
    }
    
    //用来处理某个 AppAction，并 返回新的 AppState 的 Reducer 角色
    //静态的纯函数
    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand?
        
        switch action {
        case .login(let email, let password):
            //我们在本节一开始就强调过，对于一个异步操作来说，有两个时间点比较关 键，其中一个就是操作开始的时候。在 AppState.Settings 中，我们添加一个 Bool 变量 loginRequesting 来表示登录请求是否正在进行中。为了避免重复 请求，在收到 .login Action 时，先检查是否已经在登录过程中。如果可以继续 登录，则把这个值置为 true。
            guard !appState.settings.loginReuqesting else {
                break
            }
            appState.settings.loginReuqesting = true
            
            //除了改变 loginRequesting 这个 State 值，我们还想要实际发送登录请求。这 可以通过把 appCommand 设置为 LoginAppCommand 来触发。
            appCommand = LoginAppCommand(email: email, password: password)
        case .accountBehaviorDone(let result):
            //在 .login Action 里，我们把 loginRequesting 设为了 true， .accountBehaviorDone 代表这个异步请求完成，所以不论结果如何，我们都 将这个值重置回 false。
            appState.settings.loginReuqesting = false
            switch result {
            case .success(let user):
                //如果正确登录，LoginAppCommand 将会给回有效的 User 值，我们通过将它 设定给 loginUser，可以让 View 正确显示已登录用户的信息。
                appState.settings.loginUser = user
            case .failure(let error):
                //对于错误的情况，现在只是将错误描述打印出来。我们会在下一节实现弹出提 示对话框作为简单的错误处理。
                print("Error: \(error.localizedDescription)")
                appState.settings.loginError = error
            }
        }
        return (appState, appCommand)
    }

    /** 旧版的
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
     */
}


