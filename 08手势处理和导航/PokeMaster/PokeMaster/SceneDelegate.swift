//
//  SceneDelegate.swift
//  PokeMaster
//
//  Created by Wang Wei on 2019/08/28.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let store = createStore(connectionOptions.urlContexts)
        showMainTab(scene: scene, with: store)
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let store = createStore(URLContexts)
        showMainTab(scene: scene, with: store)
    }
    
    private func createStore(_ URLContexts: Set<UIOpenURLContext>) -> Store {
        let store = Store()
        
        guard let url = URLContexts.first?.url, let components =  URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return store
        }
        
        switch (components.scheme, components.host) {
        case ("pokemaster", "showPanel"):
            guard let idQuery = (components.queryItems?.first {
                $0.name == "id"
            }),
            let idString = idQuery.value,
                let id = Int(idString),
                id >= 1 && id <= 30 else {
                break
            }
            store.appState.pokemonList.selectionState = .init(expandingIndex: id, panelIndex: id, panelPresented: true)
        default:
            break
        }
        return store
    }

    private func showMainTab(scene: UIScene, with store: Store) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: MainTab().environmentObject(store))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

