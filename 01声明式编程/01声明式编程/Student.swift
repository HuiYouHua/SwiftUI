//
//  Student.swift
//  01声明式编程
//
//  Created by 华惠友 on 2020/11/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

struct Student {
    let name: String
    let scores: [Subject: Int]
}

enum Subject: String, CaseIterable {
    case chinese, math, english, physics
}
