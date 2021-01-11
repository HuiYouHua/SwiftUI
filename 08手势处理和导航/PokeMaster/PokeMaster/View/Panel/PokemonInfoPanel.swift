//
//  PokemonInfoPanel.swift
//  PokeMaster
//
//  Created by 王 巍 on 2019/08/31.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct PokemonInfoPanel: View {

    @EnvironmentObject var store: Store

    let model: PokemonViewModel
    var abilities: [AbilityViewModel]? {
        store.appState.pokemonList.abilityViewModels(for: model.pokemon)
    }

    var topIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40, height: 6)
            .opacity(0.2)
    }

    var pokemonDescription: some View {
        Text(model.descriptionText)
            .font(.callout)
            .foregroundColor(Color(hex: 0x666666))
            .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        VStack(spacing: 20) {
            topIndicator
//            Header(model: model)
//            pokemonDescription
            Group {
                Header(model: model)
                pokemonDescription
            }.animation(nil)//由于我们添加的动画不仅作用于 VStack，也会作用于它的全部子 View。对于图示的这部分文本，我们所希望的是，即使起始状态和终结状态间的文 本宽度和高度 (行数) 不匹配，也直接显示最终状态，而不是逐渐改变宽度和高度。为 了达到这一点，在 PokemonInfoPanel 里，我们可以显式地指明不需要动画
            Divider()
            AbilityList(
                model: model,
                abilityModels: abilities)
        }
        .padding(
            EdgeInsets(
                top: 12,
                leading: 30,
                bottom: 30,
                trailing: 30
            )
        )
        .blurBackground(style: .systemMaterial)
        .cornerRadius(20)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct PokemonInfoPanel_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoPanel(model: .sample(id: 1))
    }
}
