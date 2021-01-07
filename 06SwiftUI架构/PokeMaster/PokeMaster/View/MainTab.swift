//
//  MainTab.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct MainTab: View {
    var body: some View {
        //tabItem 定义了 TabView 上对应 Tab 里应该显示的图片和文字。在 tabItem 里，只有 Image 和 Text 是被接受的，其他类型的 View 将被忽视。
        TabView {
            PokemonRootView().tabItem {
                //希望你还记得 iOS 13 开始系统为我们提供的 SF Symbol 图标。在 Tab 上显示 的图标是它的一个绝佳使用场景。
                Image(systemName: "list.bullet.below.rectangle")
                Text("列表")
            }
            SettingRootView().tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
        }.edgesIgnoringSafeArea(.top)//TabView 默认会尊重 safe area 的顶部，这会导致 TabView 里的宝可梦列表 在滚动时无法达到 “刘海屏” 上部的状态栏，这不是我们需要的。使用 .edgesIgnoringSafeArea(.top) 忽略掉 safe area，让界面占满屏幕。
    }
}
