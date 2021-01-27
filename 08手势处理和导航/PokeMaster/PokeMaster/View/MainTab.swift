//
//  MainTab.swift
//  PokeMaster
//
//  Created by Wang Wei on 2019/09/02.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct MainTab: View {

    @EnvironmentObject var store: Store

    private var pokemonList: AppState.PokemonList {
        store.appState.pokemonList
    }
    private var pokemonListBinding: Binding<AppState.PokemonList> {
        $store.appState.pokemonList
    }

    private var selectedPanelIndex: Int? {
        pokemonList.selectionState.panelIndex
    }

    var body: some View {
        TabView(selection: $store.appState.mainTab.selection) {
            PokemonRootView().tabItem {
                Image(systemName: "list.bullet.below.rectangle")
                Text("列表")
            }
            ///给每个 tabItem 加上一个类型符合要求的 tag。SwiftUI 将使用这个 tag 值来辨别所选中的 Tab。
            .tag(AppState.MainTab.Index.list)
            SettingRootView().tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
            .tag(AppState.MainTab.Index.settings)
        }
        .edgesIgnoringSafeArea(.top)
        .overlaySheet(isPresented: pokemonListBinding.selectionState.panelPresented) {
            if selectedPanelIndex != nil && pokemonList.pokemons != nil {
                PokemonInfoPanel(model: self.pokemonList.pokemons![selectedPanelIndex!]!)
            }
        }
    }
}

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab()
    }
}
