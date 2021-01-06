//
//  ContentView.swift
//  02Caclulator
//
//  Created by 华惠友 on 2020/11/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import SwiftUI




let scale: CGFloat = UIScreen.main.bounds.width / 414
struct ContentView: View {
    ///Xcode 预览使用了动态替换 body 属性的特性，但是它有一些局限:当 body 以外的部分被改变，导致 ContentView 需要整个重新编译时 (比如在 ContentView 中随意加入一个存储属性 var value = 1)，你必须再次点击 Re- sume 按钮才能重新开始预览。默认情况下刷新预览的快捷键是 Option + Command + P。
    
    var body: some View {
        ///这里如果我们设置VStack的对其方式后,那么 VStack内部的所有元素都会是该对其方式,这并不是我们需要的, 我们只需要将Text进行对其
        ///计算器按钮并不需要
        ///因此我们可以采用frame modifier的另外一个版本
        /**
         
         func frame(
         minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center
         ) !" Self.Modified<_FlexFrameLayout>
         */
        VStack(spacing: 12) {
            ///SwiftUI 允许我们定义可伸 缩的空白:Spacer，它会尝试将可占据的空间全部填满。在我们的 body 中，可以加 入一个 Spacer 来把 VStack 的上半部分全部填满。同时，为了美观，我们也可以为 Text 和 CalculatorButtonPad 添加一些必要的 padding 并且限制 lineLimit 为一行:
            Spacer()
            Text("0")
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)///.infinity不 对最大宽度进行限制
            CalculatorButtonPad()
                .padding(.bottom)
        }.scaleEffect(scale)
    }
}

///ContentView_Previews 则是一个 满足了 PreviewProvider 的 dummy 界面
///也就是右侧窗口
struct ContentView_Previews: PreviewProvider {
    /**
     这里的View 是一个协议
     该协议定义了一个关联类型 Body , 并且这个关联类型遵循了 View 协议
     同时规定了该关联类型的类型为 [自身的具体实例的实现该关联类型的类型]
     规定了 previews 属性的返回值必须要实现body这个属性, 并且要遵循 View这个协议
     public protocol View {
         associatedtype Body : View
         var body: Self.Body { get }
     }
     
     这里使用不透明类型some关键字是为了, 不需要每次对返回值类型进行声明式描述, 只要需要使用some 关键字就可以推断出具体的返回值类型
     
     如果不使用some关键词, 那么下面就应该写成
     static var previews: ContentView
     */
    static var previews: some View {
//    static var previews: ContentView {
        Group {
            ///，对于按钮尺寸和字体大小等，我们是通过硬编码的方式写死在程序中的。这 在我们预览所使用的 iPhone XR 屏幕上表现良好，但是如果在小屏幕上，可能就不尽 人意了。通过修改 previews，我们可以同时预览多个屏幕尺寸。将 previews 改写为:
//            ContentView()
            ContentView().previewDevice("iPhone SE (2nd generation)")
        }
    }
}







/**
 some 关键字
 原本使用在协议中 使用一个关联类型: associatedtype[给协议中用到的类型定义一个占位名称]
 实现该协议的类, 可以指定该关联类型为某种类型, 用于泛型
 */
protocol Runnable {
    associatedtype Speed
    var speed: Speed { get }
}
class Person: Runnable {
    var speed: Double { 0.0 }
    
    ///some关键字除了用在返回值类型上, 一般还可以用在属性类型上 [SwiftUI中就用在了属性类型上]
    ///var xxxx: some View

    var car: some Runnable {
        return Car()
    }
}
class Car: Runnable {
    var speed: Double { 0.0 }
}

class Test {
    ///如果协议中没有associatedtype, 可以直接返回遵循协议的某个对象,否则是无法明确其类型的
    ///错误说明: Protocol 'Runnable' can only be used as a generic constraint because it has Self or associated type requirements
    ///解决方式, 1.使用泛型
    func get1<T: Runnable>(_ type: Int) -> T {
        if type == 0 {
            return Person() as! T
        }
        return Car() as! T
    }
    ///2.使用不透明类型, 使用some关键字声明一个不透明类型
    ///some限制只能返回一种类型
    func get(_ type: Int) -> some Runnable {
        if type == 0 {
//            return Person()
        }
        return Car()
    }
}
///-------------------------------

protocol MyView {
    associatedtype Body: MyView
    var body: Self.Body { get }
}

struct MyContentView: MyView {
    ///比如这里body的返回值为实现了MyView协议的对象
    var body: some MyView {
        return MyText()
    }
}

class MyText: MyView {
    ///MyText实现了MyVide的协议, 同时body的类型也实现了MyView的协议[这里有问题, 不知道怎么实现, 循环了]
    var body = MyContentView()
}


class Test1 {
    static var myPreviews: some MyView {
        MyContentView()
    }
}


///正常思维的人类肯定会选择进行一定的抽象，来避免重复代码。按住 Command 并单击 Button，在弹出的菜单中选择 “Extract Subview”，可以将 这个 Button 提取为一个新的 View，把它重命名为 CalculatorButton。
struct CalculatorButton: View {
    let fontSize: CGFloat = 38
    let title: String
    let size: CGSize
    let backgroundColorName: String
    let action: () -> Void
    
    /**
     上面这四次调用，都被称为 View 的 modifier。一个 view modifier 作用在某个 View 上，并生成原来值的另一个版本。按照这个定义，大致来说，view modifier 分为两种类别:
     → 像是 font，foregroundColor 这样定义在具体类型 (比如例中的 Text) 上，然 后返回同样类型 (Text) 的原地 modifier。
     → 像是 padding，background 这样定义在 View extension 中，将原来的 View 进行包装并返回新的 View 的封装类 modifier。
     
     原地 modifier 一般来说对顺序不敏感，对布局也不关心，它们更像是针对对象 View 本身的属性的修改。而与之相反，封装类的 modifier 的顺序十分重要
     */
    ///原地 modifier返回值是自身
    ///封装类 modifier 返回的是一个View对象
    
    ///SwiftUI 中初始化按钮非常简单，调用 Button.init(action:label:) 就行了。第一个参 数 action 定义了按钮触发时的行为，第二个参数 label 接受一个闭包，它是一个 ViewBuilder，在底层，ViewBuilder 使用了所谓的 function builder 技术，来把DSL 的 View 描述转换为实际的 View 对象
    ///想要将若干个 View 并列在同一行， 可以使用 HStack，它是水平堆栈 (Horizontal Stack) 的缩写
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.system(size: fontSize))///原地 modifier
                .foregroundColor(.white)///原地 modifier
                .frame(width: size.width, height: size.height)///封装类 modifier
                .background(Color(backgroundColorName))///封装类 modifier
                .cornerRadius(size.width / 2)
        })
    }
}


struct CalculatorButtonRow: View {
    let row: [CalculatorButtonItem]
    var body: some View {
        HStack(content: {
            ForEach(row, id: \.self) { (item) in
                CalculatorButton(title: item.title, size: item.size, backgroundColorName: item.backgroundColorName) {
                    print("Button: \(item.title)")
                }
            }
        })
    }
}

struct CalculatorButtonPad: View {
    let pad: [[CalculatorButtonItem]] = [
        [.command(.clear), .command(.flip), .command(.percent), .op(.divide)],
        [.digit(7), .digit(8), .digit(9), .op(.multiply)],
        [.digit(4), .digit(5), .digit(6), .op(.minus)],
        [.digit(1), .digit(2), .digit(3), .op(.plus)],
        [.digit(0), .dot, .op(.equal)]
    ]
    var body: some View {
        VStack(spacing: 8, content: {
            ForEach(pad, id: \.self) { (row) in
                CalculatorButtonRow(row: row)
            }
        })
    }
}
