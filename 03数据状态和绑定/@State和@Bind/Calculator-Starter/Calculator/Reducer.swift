//
//  Reducer.swift
//  Calculator
//
//  Created by 华惠友 on 2020/12/15.
//  Copyright © 2020 OneV's Den. All rights reserved.
//

import UIKit

typealias CalculatorState = CalculatorBrain
typealias CalculatorStateAction = CalculatorButtonItem

struct Reducer {
    ///纯函数: 如果你对函数式编程不熟悉，可能会对 “纯函数” 的概念比较陌生。纯函数 指的是，返回值只由调用时的参数决定，而不依赖于任何系统状态，也不改 变其作用域之外的变量状态的函数。我们强调纯函数，是因为其中不存在复 杂的依赖关系，理解起来非常简单。而其优秀的特性，也让我们始终可以通 过测试来确保逻辑正确。
    ///前端的Redux
    static func reduce(
        state: CalculatorState,
        action: CalculatorStateAction
    ) -> CalculatorState {
        return state.apply(item: action)
    }
}
