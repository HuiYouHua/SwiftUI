//
//  LoadPokemonRequest.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/11.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation
import Combine

struct LoadPokemonRequest {
    
    let id: Int
    
    static var all: AnyPublisher<[PokemonViewModel], AppError> {
        (1...30).map {
            LoadPokemonRequest(id: $0).publiser
        }.zipAll
    }
    
    //请求进行组合 处理转换为 ViewModel
    var publiser: AnyPublisher<PokemonViewModel, AppError> {
        pokemonPubliser(id)
            .flatMap{ self.speciesPublisher($0) }
            .map{ PokemonViewModel(pokemon: $0, species: $1) }
            .mapError{ AppError.networkingFailed($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    //id 请求 宝可梦
    func pokemonPubliser(_ id: Int) -> AnyPublisher<Pokemon, Error> {
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!)
            .map{ $0.data }
            .decode(type: Pokemon.self, decoder: appDecoder)
            .eraseToAnyPublisher()
    }
    
    // 根据宝可梦 url 请求信息
    func speciesPublisher(_ pokemon: Pokemon) -> AnyPublisher<(Pokemon, PokemonSpecies), Error> {
        URLSession.shared.dataTaskPublisher(for: pokemon.species.url)
            .map{ $0.data }
            .decode(type: PokemonSpecies.self, decoder: appDecoder)
            .map{ (pokemon, $0) }
            .eraseToAnyPublisher()
    }
}

