//
//  PokemonInfoPanel.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct PokemonInfoPanel: View {
    
    let model: PokemonViewModel
    @State var darkBlur = false
    
    var abilities: [AbilityViewModel] {
        AbilityViewModel.sample(pokemonID: model.id)
    }
    
    var topIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40, height: 6)
            .opacity(0.2)
    }
    
    //pokemonDescription 中最后一行的 fixedSize 修饰符用来告诉 SwiftUI 保持 View 的理想尺寸，让它不被上层 View “截断”。对于 Text，默认情况下是可以显示多行文 本，而不会被截断或者限制。但是，在某些情况下 Text 的行为会被改变，而让本应多 行的文本被显示为单行 (比如在 Xcode 11.1 中，发生拖拽时文本就无法完全显示，这 大概率是 SwiftUI 的 bug)，通过 .fixedSize(horizontal: false, vertical: true)，可以 在竖直方向上显示全部文本，同时在水平方向上保持按照上层 View 的限制来换行。
    //默认情况 Text 会显示全部文本，如果想要限制行数 (比如显示两行，其余用 ... 截断)，可以设置 .lineLimit(2)。
    var pokemonDescription: some View {
        Text(model.descriptionText)
            .font(.callout)
            .foregroundColor(Color(hex: 0x666666))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                self.darkBlur.toggle()
            }, label: {
                Text("切换模糊效果")
            })
            topIndicator
            Header(model: model)
            pokemonDescription
            Divider()
            AbilityList(model: model, abilityModels: abilities)
        }
        
        .padding(EdgeInsets(top: 12, leading: 30, bottom: 30, trailing: 30))
        
//        .background(Color.white)
        .blurBackground(style: darkBlur ? .systemMaterialDark : .systemMaterial)
        //idealHeight 和 fixedSize 配合能限制区域
//        .frame(idealHeight: 600)
        .cornerRadius(20)
        .fixedSize(horizontal: false, vertical: true)


    }
}

