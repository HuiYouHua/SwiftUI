//
//  PokemonInfoPanelAbilityList.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI


extension PokemonInfoPanel {
    struct AbilityList: View {
        
        let model: PokemonViewModel
        let abilityModels: [AbilityViewModel]?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("技能").font(.headline).fontWeight(.bold)
                if abilityModels != nil {
                    ForEach(abilityModels!) { ability in
                        Text(ability.name).font(.subheadline).foregroundColor(self.model.color)
                        Text(ability.descriptionText).font(.footnote).foregroundColor(Color(hex: 0xAAAAAA)).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
}
