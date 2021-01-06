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

/**
 @State 非常适合 struct 或者 enum 这样的值类型，它可以自动为我们完成从状态 到 UI 更新等一系列操作。但是它本身也有一些限制，我们在使用 @State 之前，对 于需要传递的状态，最好关心和审视下面这两个问题:
 1. 这个状态是属于单个 View 及其子层级，还是需要在平行的部件之间传递和使 用?@State 可以依靠 SwiftUI 框架完成 View 的自动订阅和刷新，但这是有 条件的:对于 @State 修饰的属性的访问，只能发生在 body 或者 body 所调 用的方法中。你不能在外部改变 @State 的值，它的所有相关操作和状态改变 都应该是和当前 View 挂钩的。如果你需要在多个 View 中共享数据，@State 可能不是很好的选择;如果还需要在 View 外部操作数据，那么 @State 甚至 就不是可选项了。
 2. 状态对应的数据结构是否足够简单?对于像是单个的Bool或者String， @State 可以迅速对应。含有少数几个成员变量的值类型，也许使用 @State 也还不错。但是对于更复杂的情况，例如含有很多属性和方法的类型，可能其 中只有很少几个属性需要触发 UI 更新，也可能各个属性之间彼此有关联，那 么我们应该选择引用类型和更灵活的可自定义方式。
 在本节中，我们将会设计和实现一种机制，用它来记录计算器的按键操作，并且提供 UI 让用户可以返回到任意次之前的状态。这就是一个不太适合使用 @State 的例子: 会有多个 View 共享和更改模型数据，而且当前的输入状态和历史操作的输入记录之 间是紧密联系的。对于这样的不适合选择 @State 的情况 (往往这是实际数据传递中 更普遍的情况)，ObservableObject 和 @ObservedObject 是解决的方案。
 
 
 ObservableObject 和 @ObjectBinding
 如果说 @State 是全自动驾驶的话，ObservableObject 就是半自动，它需要一些额 外的声明。ObservableObject 协议要求实现类型是 class，它只有一个需要实现的
 更多iOS课程，加V获取:iOS77777iOS
 属性:objectWillChange。在数据将要发生改变时，这个属性用来向外进行 “广播”， 它的订阅者 (一般是 View 相关的逻辑) 在收到通知后，对 View 进行刷新。
 创建 ObservableObject 后，实际在 View 里使用时，我们需要将它声明为 @ObservedObject。这也是一个属性包装，它负责通过订阅 objectWillChange 这个 “广播”，将具体管理数据的 ObservableObject 和当前的 View 关联起来。
 */
struct ContentView : View {
    
    ///在 ContentView 里将 @State 的内容都换成对应的 @ObservedObject 和 CalculatorModel:
    ///1. model 现在是一个引用类型 CalculatorModel 的值，使用 @ObservedObject 将它和 ContentView 关联起来。当 CalculatorModel 中的 objectWillChange 发出事件时，body 会被调用，UI 将被刷新。
    ///2. brain 现在是 model 的属性。
    ///3. CalculatorButtonPad 接受的是 Binding<CalculatorBrain>。model 的 $ 投影 属性返回的是一个 Binding 的内部 Wrapper 类型，对它再进行属性访问 (这里的 .brain)，将会通过动态查找的方式获取到对应的 Binding<CalculatorBrain>。
    
    ///CalculatorButtonPad 通过和 @State 时同样的方式，将 brain 的 Binding 传递给 CalculatorButtonRow，并在按下按钮时重新设置状态值。这个对 model.brain 的设 置，触发了 CalculatorModel 中 brain 的 willSet，并通过 objectWillChange 把事件 广播出去。订阅了这个事件的 ContentView 在收到变更通知后，进行 UI 刷新。
//    @ObservedObject var model = CalculatorModel()
    
    /**
     为了让除 ContentView 以外的其他 View (比如 CalculatorButtonPad， CalculatorButtonRow 和 HistoryView 等) 也能访问到同样的模型，我们现在通过它 们的初始化方法将 model 进行传递。这在传递链条比较短，或者是链条上每个 View 都需要 model 时是相对合理的。但是，在很多时候实际情况会不同，比如计算器例 子中 CalculatorButtonPad 其实完全不需要知道 model 的任何信息，它做的仅仅只 是把这个值向下传递。在 SwiftUI 中，View 提供了 environmentObject(_:) 方法，来 把某个 ObservableObject 的值注入到当前 View 层级及其子层级中去。在这个 View 的子层级中，可以使用 @EnvironmentObject 来直接获取这个绑定的环境值。
     
     可能一开始你会认为 @EnvironmentObject 和 “臭名昭著” 的单例很像:只要我们在 View 的层级上，不论何处都可以访问到这个环境对象。看似这会带来状态管理上的 困难和混乱，但是 Swift 提供了清晰的状态变更和界面刷新的循环，如果我们能选择 正确的设计和架构模式，完全可以避免这种风险。使用 @EnvironmentObject 带来 很大的便捷性，也避免了大量不必要的属性传递，这会为之后代码变更带来更多的 好处。
     */
    @EnvironmentObject var model: CalculatorModel
    
    @State private var editingHistory = false
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            ///.sheet 调用将会在它的 isPresented 为 true 的时候以 modal 的方式展示一个在尾 随闭包中定义的 View (这里就是 HistoryView)。为了追踪这个 isPresented，我们需 要在 ContentView 添加一个 @State:editingHistory。当 Button 被按下后， editingHistory 的值被设为 true，触发 modal 行为和 HistoryView 的展示。当用户 使用手势关闭 HistoryView 时，SwiftUI 会通过 self.$editingHistory 这个 Binding 把值设回 false。

            Button("操作记录1: \(model.history.count)") {
                editingHistory = true
            }.sheet(isPresented: self.$editingHistory) {
                HistoryView(model: self.model)
            }
            
            Text(model.brain.output)
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24 * scale)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .trailing)
            CalculatorButtonPad()
                .padding(.bottom)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView().previewDevice("iPhone SE")
            ContentView().previewDevice("iPad Air 2")
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
    
//    @Binding var brain: CalculatorBrain
//    var model: CalculatorModel
    @EnvironmentObject var model: CalculatorModel

    var body: some View {
        HStack {
            ForEach(row, id: \.self) { item in
                CalculatorButton(
                    title: item.title,
                    size: item.size,
                    backgroundColorName: item.backgroundColorName,
                    foregroundColor: item.foregroundColor)
                {
//                    self.brain = self.brain.apply(item: item)
                    self.model.apply(item)
                }
            }
        }
    }
}

struct CalculatorButtonPad: View {
    
//    @Binding var brain: CalculatorBrain
//    var model: CalculatorModel
    
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
                CalculatorButtonRow(row: row)
            }
        }
    }
}


struct HistoryView: View {
    @ObservedObject var model: CalculatorModel
    var body: some View {
        VStack {
            if model.totalCount == 0 {
                Text("没有履历")
            } else {
                HStack {
                    Text("履历").font(.headline)
                    Text("\(model.historyDetail)").lineLimit(nil)
                }
                HStack {
                    Text("显示").font(.headline)
                    Text("\(model.brain.output)")
                }
                Slider(value: $model.slidingIndex, in: 0...Float(model.totalCount), step: 1)
            }
        }.padding()
    }
}

/**
 总结:
 本章中，我们看到了 SwiftUI 中的几种处理数据和逻辑的方式。根据适用范围和存储 状态的复杂度的不同，需要选取合适的方案。@State 和 @Binding 提供 View 内部 的状态存储，它们应该是被标记为 private 的简单值类型，仅在内部使用。 ObservableObject 和 @ObservedObject 则针对跨越 View 层级的状态共享，它可以
 更多iOS课程，加V获取:iOS77777iOS
 处理更复杂的数据类型，其引用类型的特点，也让我们需要在数据变化时通过某种 手段向外发送通知 (比如手动调用 objectWillChange.send() 或者使用 @Published)， 来触发界面刷新。对于 “跳跃式” 跨越多个 View 层级的状态，@EnvironmentObject 能让我们更方便地使用 ObservableObject，以达到简化代码的目的。
 随着经验的积累，你会逐渐形成对于某个场景下应该使用哪种方式来管理数据和状 态的直觉。在此之前，如果你纠结于选择使用哪种方式的话，从 ObservableObject 开始入手会是一个相对好的选择:如果发现状态可以被限制在同一个 View 层级中， 则改用 @State;如果发现状态需要大批量共享，则改用 @EnvironmentObject。
 */
