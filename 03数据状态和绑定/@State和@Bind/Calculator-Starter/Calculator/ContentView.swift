//
//  ContentView.swift
//  Calculator
//
//  Created by Wang Wei on 2019/06/17.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI
import Combine

let scale = UIScreen.main.bounds.width / 414


struct TestContentView: View {
    @Converter(initialValue: "100", from: "USD", to: "CNY", rate: 6.88)
    var usd_cny
    
    @Converter(initialValue: "100", from: "CNY", to: "USD", rate: 0.13)
    var cny_eur
    
    var body: some View {
        VStack{
            Text("\(usd_cny) = \($usd_cny)")
            Text("\(cny_eur) = \($cny_eur)")
            Button("改变") {
//                self.usd_cny = "324.3"
            }
        }
    }
}

struct ContentView : View {
    
    ///和一般的存储属性不同，@State 修饰的值，在 SwiftUI 内部会被自动转换为一对 setter 和 getter，对这个属性进行赋值的操作将会触发 View 的刷新，它的 body 会 被再次调用，底层渲染引擎会找出界面上被改变的部分，根据新的属性值计算出新 的 View，并进行刷新。
    @State private var brain: CalculatorBrain = .left("0")
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(brain.output)
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24 * scale)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .trailing)
            Button("Test") {
                self.brain = .left("1.23")
            }
            ///3.接下来，把 ContentView 中的 brain 通过 CalculatorButtonPad 的初始化方法进行 传递;类似地，在 CalculatorButtonPad 中也通过初始化方法将 binding 传递到 CalculatorButtonRow 里:
            CalculatorButtonPad(brain: $brain)
                .padding(.bottom)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            TestContentView()
//            ContentView()
//            ContentView().previewDevice("iPhone SE")
//            ContentView().previewDevice("iPad Air 2")
        }
    }
}

struct CalculatorButton : View {

    let fontSize: CGFloat = 38
    let title: String
    let size: CGSize
    let backgroundColorName: String
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize * scale))
                .foregroundColor(foregroundColor)
                .frame(width: size.width * scale, height: size.height * scale)
                .background(Color(backgroundColorName))
                .cornerRadius(size.width * scale / 2)
        }
    }
}

struct CalculatorButtonRow : View {
    
    let row: [CalculatorButtonItem]
    ///在传递 brain 时，我们在它前面加上美元符号 $。在 Swift 5.1 中，对一个由 @ 符号 修饰的属性，在它前面使用 $ 所取得的值，被称为投影属性 (projection property)。 有些 @ 属性，比如这里的 @State 和 @Binding，它们的投影属性就是自身所对应 值的 Binding 类型。不过要注意的是，并不是所有的 @ 属性都提供 $ 的投影访问方 式。我们会在下一节中看到更详细的说明。在这里，你只需要知道 $brain 的写法将 brain 从 State 转换成了引用语义的 Binding，并向下传递。这样一来，底层 CalculatorButtonRow 中对 brain 的修改，将反过来影响和设置最顶层 ContentView 中的 @State brain。
    @Binding var brain: CalculatorBrain

    var body: some View {
        HStack {
            ForEach(row, id: \.self) { item in
                CalculatorButton(
                    title: item.title,
                    size: item.size,
                    backgroundColorName: item.backgroundColorName,
                    foregroundColor: item.foregroundColor)
                {
                    self.brain = self.brain.apply(item: item)
                }
            }
        }
    }
}

struct CalculatorButtonPad: View {
    
    ///1.CalculatorButton 被层层包围，“深埋” 在 CalculatorButtonPad 和 CalculatorButtonRow 中。它没有办法直接访问和改变顶层 ContentView 中的 brain 属性。@State 属性值仅只能在属性本身被设置时会触发 UI 刷新，这个特性让 它非常适合用来声明一个值类型的值:因为对值类型的属性的变更，也会触发整个 值的重新设置，进而刷新 UI。不过，在把这样的值在不同对象间传递时，状态值将 会遵守值语义发生复制。所以，即使我们将 ContentView 里的 brain 通过参数的方 式层层向下，传递给 CalculatorButtonPad 和 CalculatorButtonRow，最后在按钮 事件中，因为各个层级中的 brain 都不相同，按钮事件对 brain 的变更也只会作用在 同层级中，无法对 ContentView 中的 brain 进行改变，因此顶层的 Text 无法更新。
    ///@Binding 就是用来解决这个问题的。和 @State 类似，@Binding 也是对属性的修 饰，它做的事情是将值语义的属性 “转换” 为引用语义。对被声明为 @Binding 的属 性进行赋值，改变的将不是属性本身，而是它的引用，这个改变将被向外传递。
    ///2.修改 CalculatorButtonPad 和 CalculatorButtonRow 的定义，分别为它们加上 @Binding 的 brain:
    @Binding var brain: CalculatorBrain
    
    let pad: [[CalculatorButtonItem]] = [
        [.command(.clear), .command(.flip),
         .command(.percent), .op(.divide)],
        [.digit(7), .digit(8), .digit(9), .op(.multiply)],
        [.digit(4), .digit(5), .digit(6), .op(.minus)],
        [.digit(1), .digit(2), .digit(3), .op(.plus)],
        [.digit(0), .dot, .op(.equal)]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(pad, id: \.self) { row in
                CalculatorButtonRow(row: row, brain: $brain)
            }
        }
    }
}
