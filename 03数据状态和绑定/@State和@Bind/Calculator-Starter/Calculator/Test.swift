//
//  Test.swift
//  Calculator
//
//  Created by 华惠友 on 2020/12/15.
//  Copyright © 2020 OneV's Den. All rights reserved.
//

import UIKit

/**
 propertyWrapper
 上面提到过多次的 @ 属性做一些更正式的说明。在 Swift 中，这一特性的正式名称是属性包装 (Property Wrapper)。不论是 @State， @Binding，或者是我们在下一节中将要看到的 @ObjectBinding 和 @EnvironmentObject，它们都是被 @propertyWrapper 修饰的 struct 类型。以 State 为例，在 SwiftUI 中 State 定义的关键部分如下:
 @propertyWrapper
 public struct State<Value> :DynamicViewProperty, BindingConvertible {
     public init(initialValue value: Value)
     public var value: Value { get nonmutating set }
     public var wrappedValue: Value { get nonmutating set }
     public var projectedValue: Binding<Value> { get }
 }
 init(initialValue:)，wrappedValue 和 projectedValue 构成了一个 propertyWrapper 最重要的部分
 1. 由于 init(initialValue:) 的存在，我们可以使用直接给 brain 赋值的写法，将一 个 CalculatorBrain 传递给 brain。我们可以为属性包装中定义的 init 方法添 加更多的参数，我们会在接下来看到一个这样的例子。不过 initialValue 这个 参数名相对特殊:当它出现在 init 方法的第一个参数位置时，编译器将允许我 们在声明的时候直接为 @State var brain 进行赋值。
 
 2. 在访问 brain 时，这个变量暴露出来的就是 CalculatorBrain 的行为和属性。 对 brain 进行赋值，看起来也就和普通的变量赋值没有区别。但是，实际上这 些调用都触发的是属性包装中的 wrappedValue。@State 的声明，在底层将 brain 属性 “包装” 到了一个 State<CalculatorBrain> 中，并保留外界使用者 通过 CalculatorBrain 接口对它进行操作的可能性。
 
 3. 使用美元符号前缀 ($) 访问 brain，其实访问的是 projectedValue 属性。在 State 中，这个属性返回一个 Binding 类型的值，通过遵守 BindingConvertible，State 暴露了修改其内部存储的方法，这也就是为什么 传递 Binding 可以让 brain 具有引用语义的原因。
 */

@propertyWrapper
struct Converter {
    let from: String
    let to: String
    let rate: Double
    
    /**
     Converter 提供的 init 方法除了 initialValue 外，还接受 from，to 和 rate，它们分 别代表转换货币的名称和汇率。属性中 wrappedValue 是 String 类型，表示我们希 望包装一个字符串:它提供的 setter 负责将字符串转换为数字并存储 (当用户输入无
     法转换为数字时，用 -1 代表错误)，getter 则输出源货币的信息。而访问 projectedValue 则能得到转换后的货币信息。
     */
    init(
        initialValue: String,
        from: String,
        to: String,
        rate: Double
    ) {
        self.value = 0
        self.from = from
        self.to = to
        self.rate = rate
        self.wrappedValue = initialValue
    }
    
    var value: Double
    
    var wrappedValue: String {
        get { "\(from) \(value)" }
        set { value = Double(newValue) ?? -1 }
    }
    
    var projectedValue: String {
        return "\(to) \(value * rate)"
    }
}

