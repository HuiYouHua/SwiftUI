//
//  AppState.swift
//  PokeMaster
//
//  Created by Wang Wei on 2019/09/04.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import Combine
import Foundation

struct AppState {
    var settings = Settings()
    var pokemonList = PokemonList()
}

extension AppState {
    struct Settings {
        enum Sorting: CaseIterable {
            case id, name, color, favorite
        }

        enum AccountBehavior: CaseIterable {
            case register, login
        }

        //Publisher 在 Combine 中是一切的源头，为相关属性创建 Publisher 是我们要做的 第一步。对于属性值来说，最简单的方式是在属性声明前面加上 @Published 标记。但是 @Published 需要在内部生成并持有存储，因此我们只能针对定义在 class 里 的变量添加 @Published。当前，AppState.Settings 是一个 struct，我们的第一步 是要将 email，accountBehavior 提取到 class 中。
        class AccountChecker {
            @Published var accountBehavior = AccountBehavior.login
            @Published var email = ""
            @Published var password = ""
            @Published var verifyPassword = ""
            
            /**
             1. 在本地检测用户输入的是不是有效的邮箱地址。
             2. 使用用户的输入访问 API，判断是不是重复的邮箱。我们需要减少请求量，所
                以需要对用户输入做防抖和去重。
             3. 如果用户在登录界面，而非注册界面时，不需要检查邮箱是否重复。
             4. 将这些状态组合起来，变成一个新的状态，用它去驱动 UI。
             */
            //1. isEmailValid 是一个验证用户输入的 Publisher。我们稍后会订阅它，并用它 来更新 UI。
            var isEmailValid: AnyPublisher<Bool, Never> {
                //2. remoteVerify 是构成整个 isEmailValid 的一部分，它负责调用 Server API 来 验证有效性。首先，针对 $email 使用 debounce 和 removeDuplicates 来控 制用户输入，它将为我们过滤掉输入抖动和重复输入，这样我们将能尽量减少 API 调用。
                let remoteVerify = $email.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main).removeDuplicates()
                    .flatMap { email -> AnyPublisher<Bool, Never> in
                        let validEmail = email.isValidEmailAddress
                        let canSkip = self.accountBehavior == .login
                        
                        switch (validEmail, canSkip) {
                        case (false, _):
                            ////3. 如果 validEmail 为 false，那说明输入的邮箱地址在本地就被验证为无效，就 不需要再进一步去发送检查了。
                            return Just(false).eraseToAnyPublisher()
                        case (true, false):
                            //4. 如果本地检查通过，而且我们处于注册页面时，发送 EmailCheckingRequest 请求。
                            return EmailCheckRequest(email: email).publisher.eraseToAnyPublisher()
                        case (true, true):
                            return Just(true).eraseToAnyPublisher()
                        }
                    }
                
                let emailLocalValid = $email.map{ $0.isValidEmailAddress }
                let canSkipRemoteVerify = $accountBehavior.map{ $0 == .login }
                
                //5. 把 remoteVerify 和其他状态组合起来，返回最终代表 email 是否有效的 Publisher。我们会在稍后继续在这里添加内容。
                return Publishers.CombineLatest3(emailLocalValid, canSkipRemoteVerify, remoteVerify).map{ $0 && ($1 || $2) }.eraseToAnyPublisher()
                
            }
        }
        
        var checker = AccountChecker()
        
        var isEmailValid: Bool = false
        
        var showEnglishName = true
        var sorting = Sorting.id
        var showFavoriteOnly = false

        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: User?

        var loginRequesting = false
        var loginError: AppError?
    }
}

extension AppState {
    struct PokemonList {
        @FileStorage(directory: .cachesDirectory, fileName: "pokemon.json")
        var pokemons: [Int: PokemonViewModel]?
        var loadingPokemons = false
        
        var allPokemonById: [PokemonViewModel] {
            guard let pokemons = pokemons?.values else { return [] }
            
            return pokemons.sorted { $0.id < $1.id }
        }
    }
}
