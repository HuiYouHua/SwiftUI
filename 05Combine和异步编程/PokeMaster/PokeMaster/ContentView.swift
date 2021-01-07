//
//  ContentView.swift
//  PokeMaster
//
//  Created by Wang Wei on 2019/08/28.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        PokemonRootView()
//        SettingRootView()
        TabView(content:  {
                    PokemonRootView().tabItem { Text("宝可梦列表") }.tag(1)
                    SettingRootView().tabItem { Text("设置") }.tag(2)
                })
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
