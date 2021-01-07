//
//  PokemonList.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct PokemonList: View {
    
    //用 expandingIndex 追踪选中 cell 的 index，nil 表示没有任何 cell 被选中。在 PokemonList 中添加 @State 将会使该属性被修改时触发 ScrollView 的计算 和重绘，以保证尺寸正确。
    @State var expandingIndex: Int?
    
    var body: some View {
        //List 是最传统的构建列表的方式。它接受一个数组，数组中的元素需要遵守 Identifiable 协议。该协议只有一个要求，那就是用来辨别某个值的 id:
        //但是目前listView有个分割线, 并没有API可以去去除
//        List(PokemonViewModel.all) { pokemon in
//            PokemonInfoRow(model: pokemon, expand: false)
//        }
        
        //使用scrollView, ScrollView 暂时没有内建的 cell 重用机制
        ScrollView {
            ForEach(PokemonViewModel.all) { pokemon in
                //PokemonInfoRow 的 expanded 现在需要通过比较 pokemon.id 和存储的 expandingIndex 来得出。两者相同，表示 cell 需要被展开。
                PokemonInfoRow(model: pokemon, expand: self.expandingIndex == pokemon.id)
                    .onTapGesture {//为这个 cell 添加了一个点击的手势，在触发时将 expanded 状态进行翻转。 Tap Gesture 是最简单的手势操作
                        withAnimation(
                            .spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)
                        ) {
                            //显式动画通过明确的 withAnimation 调用触发，我们可以将改变 app 状态的操作放 在 withAnimation 的闭包中，这时由闭包中状态变化所触发的 View 变化，将以动画 形式呈现。比如，将上面的 .animation 语句去掉，转而在 onTapGesture 中使用显 式动画
                            //将 onTapGesture 从 cell 移出来，并且添加上 “点击已展开的 cell，则将其缩 回” 的逻辑。
                            if self.expandingIndex == pokemon.id {
                                self.expandingIndex = nil
                            } else {
                                self.expandingIndex = pokemon.id
                            }
                        }
            
                    }
            }
        }.overlay(
            //overlay 在当前 View (ScrollView) 上方添加一层另外的 View。它的行为和 ZStack 比较相似，只不过 overlay 会尊重它下方的原有 View 的布局，而不像 ZStack 中的 View 那样相互没有约束。不过对于我们这个例子，overlay 和 ZStack 的行为没有区别，这里选择 overlay 纯粹是因为嵌套少一些，语法更 简单。
            VStack {
                Spacer()
                PokemonInfoPanel(model: .sample(id: 1))
            }.edgesIgnoringSafeArea(.bottom)//iPhone X 系列的设备引入了 safe area 的概念，SwiftUI 中自定义的一般 View 是以 safe area 为布局边界的。如果我们想要弹出面板覆盖屏幕底部，需要明 确指出忽略 safe area。
        )
    }
}
