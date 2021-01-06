//
//  CalculatorModel.swift
//  Calculator
//
//  Created by 华惠友 on 2020/12/15.
//  Copyright © 2020 OneV's Den. All rights reserved.
//

import SwiftUI
import Combine

class CalculatorModel: ObservableObject {

    ///在 ObservableObject 中，对于每个对界面可能产生影响的属性，我们都可以像上面 brain 的 willSet 那样，手动调用 objectWillChange.send()。如果在 model 中有很多 属性，我们将需要为它们一一添加 willSet，这无疑是非常麻烦，而且全是重复的模 板代码。实际上，如果我们省略掉自己声明的 objectWillChange，并把属性标记为 @Published，编译器将会帮我们自动完成这件事情
    ///在 ObservableObject 中，如果没有定义 objectWillChange，编译器会为你自动生成 它，并在被标记为 @Published 的属性发生变更时，自动去调用 objectWillChange.send()。这样就省去了我们一个个添加 willSet 的麻烦。
    @Published var brain: CalculatorBrain = .left("0")
    
    ///回溯操作模型
    @Published var history: [CalculatorButtonItem] = []
    
    func apply(_ item: CalculatorButtonItem) {
        brain = brain.apply(item: item)
        history.append(item)
        
        temporaryKept.removeAll()
        slidingIndex = Float(totalCount)
    }
    
    /**
     1. historyDetail 将 history 数组中所记录的操作步骤的描述连接起来，作为履历 的输出字符串。
     2. 在回溯操作时，除了维护 history 并让 historyDetail 反映当前的历史步骤的 同时，我们也希望保留那些 “被回溯” 的操作，这样我们可以还能使用滑块恢 复这些操作。用 temporaryKept 来暂存这些操作。
     3. 滑块的最大值应当是 history 和 temporaryKept 两个数组元素数量的和。
     4. 使用 slidingIndex 表示当前滑块表示的 index 值，这个值应该是 0 到 totalCount 之间的一个数字。事实上我们应该选用 Int 作为 slidingIndex 的类 型，但是 SwiftUI 中代表滑块的 Slider 只接受浮点数的值。我们想要将 model 的这个属性绑定到 UI 上，需要有符合的类型。
     5. slidingIndex 的 didSet 会在滑块值变动时被调用，在这里我们需要根据当前 回溯的位置决定 history 和 temporaryKept 的内容。
     */
    var historyDetail: String {
        history.map{ $0.description }.joined()
    }
    
    var temporaryKept: [CalculatorButtonItem] = []
    
    var totalCount: Int {
        history.count + temporaryKept.count
    }
    
    var slidingIndex: Float = 0 {
        didSet {
            ///维护 `history` 和 `temporaryKept`
            keepHistory(upTo: Int(slidingIndex))
        }
    }
    
    func keepHistory(upTo index: Int) {
        precondition(index <= totalCount, "Out of index.")

        let total = history + temporaryKept

        history = Array(total[..<index])
        temporaryKept = Array(total[index...])

        brain = history.reduce(CalculatorBrain.left("0")) {
            result, item in
            result.apply(item: item)
        }
    }
    
    ///PassthroughSubject 提供了一个 send 方法，来通知外界有事件要发生了 (此处的事件即驱动 UI 的数据将 要发生改变)。
//    let objectWillChange = PassthroughSubject<Void, Never>()
//
//    var brain: CalculatorBrain = .left("0") {
//        willSet { objectWillChange.send() }
//    }
}
