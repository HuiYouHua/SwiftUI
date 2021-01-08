//
//  User.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/8.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation

//这是一个 Codable 类型，我们稍后会通过一个虚拟的请求获取数据，并将 User 实例序列化为 JSON 保存在磁盘上，这样我们就不需要每次都登录了。 Codable 不是本章的重点，但它可以让这件事情非常方便。
struct User: Codable {
    var email: String
    
    //我们同时还保存了一个 favoritePokemonIDs 集合，用户使用宝可梦列表中的 “最爱” 按钮，可以将对应的宝可梦添加到这个集合中。
    var favoritePokemonIDs: Set<Int>
    
    //列表中 cell 里的 “最爱” 按钮会依据用户状态显示不同颜色， isFavoritePokemon 帮助获取最爱的状态。
    func isFavoritePokemon(id: Int) -> Bool {
        favoritePokemonIDs.contains(id)
    }
}
