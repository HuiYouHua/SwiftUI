//
//  UserDefaultsStorage.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/11.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefaultsBoolStorage {
    var value: Bool
    
    let key: String
    
    init(initialValue: Bool, key: String) {
        self.value = initialValue
        self.key = key
    }
    
    var wrappedValue: Bool {
        set {
            value = newValue
            UserDefaults.standard.set(value, forKey: key)
        }
        
        get {
            UserDefaults.standard.bool(forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultsStringStorage {
    var value: Sorting
    
    let key: String
    
    init(initialValue: Sorting, key: String) {
        self.value = initialValue
        self.key = key
    }
    
    var wrappedValue: Sorting {
        set {
            value = newValue
            UserDefaults.standard.set(value.rawValue, forKey: key)
        }
        
        get {
            let str = UserDefaults.standard.string(forKey: key) ?? value.rawValue
            return Sorting.init(rawValue: str) ?? .id
        }
    }
}
