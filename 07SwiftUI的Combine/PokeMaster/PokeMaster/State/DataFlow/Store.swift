//
//  Store.swift
//  PokeMaster
//
//  Created by 王 巍 on 2019/09/03.
//  Copyright © 2019 OneV's Den. All rights reserved.
//


import Combine

class Store: ObservableObject {
    
    @Published var appState = AppState()
    
    var disposeBag = [AnyCancellable]()
    
    init() {
        setupObservers()
    }
    
    //现在，Settings.isEmailValid 在用户输入时没有发生任何改变，所以用户输入会一 直是红色。我们更倾向于在 app 开始时就把所有内容设定好，并用声明式和响应式 的方法让 app 维护自己的状态，因此，订阅的一个比较好的时机是在 Store 的初始 化方法中:
    func setupObservers() {
        appState.settings.checker.isEmailValid.sink { (isValid) in
            self.dispatch(.emailValid(valid: isValid))
        }.store(in: &disposeBag)
    }

    func dispatch(_ action: AppAction) {
        #if DEBUG
        print("[ACTION]: \(action)")
        #endif
        let result = Store.reduce(state: appState, action: action)
        appState = result.0
        if let command = result.1 {
            #if DEBUG
            print("[COMMAND]: \(command)")
            #endif
            command.execute(in: self)
        }
    }

    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand?

        switch action {
        case .login(let email, let password):
            guard !appState.settings.loginRequesting else { break }
            appState.settings.loginRequesting = true
            appCommand = LoginAppCommand(email: email, password: password)
        case .accountBehaviorDone(let result):
            appState.settings.loginRequesting = false
            switch result {
            case .success(let user):
                appState.settings.loginUser = user
            case .failure(let error):
                appState.settings.loginError = error
            }
        case .logout:
            appState.settings.loginUser = nil
        case .emailValid(let valid):
            appState.settings.isEmailValid = valid
            
            
        case .loadPokemons:
            if appState.pokemonList.loadingPokemons { break }
            appState.pokemonList.loadingPokemons = true
            appCommand = LoadPokemonsCommand()
        case .loadPokemonsDone(let result):
            switch result {
            case .success(let models):
                //models 的类型是 [PokemonViewModel]。Dictionary 的 init(uniqueKeysWithValues:) 将一个键值对序列转换为字典，其中键值对的 首个元素会被作为 key。
                appState.pokemonList.pokemons = Dictionary(uniqueKeysWithValues: models.map{ ($0.id, $0) })
            case .failure(let error):
                print(error)
            }
        }

        return (appState, appCommand)
    }
}
