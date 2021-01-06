//
//  PokemonInfoPanelHeader.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

//相比于新建一个顶级的 PokemonInfoPanelHeader，将 Header 定义在 PokemonInfoPanel 的 extension 中，可以利用上下文获得更简洁明确的命 名。
extension PokemonInfoPanel {
    struct Header: View {
        let model: PokemonViewModel
        
        var pokemonIcon: some View {
            Image("Pokemon-\(model.id)")
                    .resizable()
                    .frame(width: 68, height: 68)
        }
        
        var nameSpecies: some View {
            VStack() {
                VStack(spacing: 18) {
                    Text(model.name)
                        .fontWeight(.bold)
                        .font(.system(size: 22))
                        .foregroundColor(model.color)
                    Text(model.nameEN)
                        .fontWeight(.bold)
                        .font(.system(size: 13))
                        .foregroundColor(model.color)
                }
                Text(model.genus)
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        
        var verticalDivider: some View {
            RoundedRectangle(cornerRadius: 1)
                .frame(width: 1, height: 44)
                .opacity(0.1)
        }
        
        var bodyStatus: some View {
            VStack {
                HStack {
                    Text("身高")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(model.height)
                        .font(.system(size: 11))
                        .foregroundColor(model.color)
                }
                HStack {
                    Text("体重")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(model.weight)
                        .font(.system(size: 11))
                        .foregroundColor(model.color)
                }
            }
        }
        
        var typeInfo: some View {
            HStack {
                ForEach(self.model.types) { t in
                    ZStack {
                        RoundedRectangle(cornerRadius: 7).fill(t.color).frame(width: 36, height: 14)
                        Text(t.name).font(.system(size: 10)).foregroundColor(.white)
                    }
                }
                
            }
        }
        
        var body: some View {
            HStack(spacing: 18) {
                pokemonIcon
                nameSpecies
                verticalDivider
                VStack(spacing: 12) {
                    bodyStatus
                    typeInfo
                }
            }
        }
    }
}
