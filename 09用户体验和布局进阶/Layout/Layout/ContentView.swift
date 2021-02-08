//
//  ContentView.swift
//  Layout
//
//  Created by 华惠友 on 2021/1/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        TriangleArrow().fill(Color.green).frame(width: 80, height: 80)
//        FlowRectangle()//.frame(width: 300, height: 600)
        /**
         通过 .layoutPriority，我们可以控制计算布局的优先级，让父 View 优先对某个子 View 进 行考虑和提案
         
         强制固定尺寸:
         除去那些刻意而为的自定义绘制，SwiftUI 中默认情况下 View 所显示的内容的尺寸 一般不会超出 View 自身的边界:比如 Text 会通过换行和截取省略来尽可能让内容 满足边界。有些罕见情况下我们可能希望无论如何，不管 View 的可用边界如何设定， 都要完整显示内容。这时候，可以使用 fixedSize。这个 modifier 将提示布局系统忽 略掉外界条件，让被修饰的 View 使用它在无约束下原本应有的理想尺寸。
         
         Frame:
         如果我们把 fixedSize 从 frame 之前拿到 frame 之后的话，会发 现布局和不加 fixedSize 的时候完全一致。这至少给我们提供了一个很重要的暗示: 这些 modifier 的调用顺序不同，可能会产生不同的结果。
         究其原因，这是由于大部分 View modifier 所做的，并不是 “改变 View 上的某个属 性”，而是 “用一个带有相关属性的新 View 来包装原有的 View”。frame 也不例外: 它并不是将所作用的 View 的尺寸进行更改，而是新创建一个 View，并强制地用指 定的尺寸，对其内容 (其实也就是它的子 View) 进行提案。这也是为什么将 fixedSize 写在 frame 之后会变得没有效果的原因:因为 frame 这个 View 的理想尺寸就是宽 度 200，它已经是按照原本的理想尺寸进行布局了，再用 fixedSize 包装也不会带来 任何改变。

         */
        HStack {
            Image(systemName: "person.circle").background(Color.yellow)
            Text("User:").background(Color.red)
            Text("huayoyu | Hui You").layoutPriority(1).background(Color.green)
        }
        .lineLimit(1)
        .fixedSize()//我们如果在 frame 之前添加 fixedSize，那么原本被缩略 的 “User:” 也将被显示出来。
        .frame(width: 300, alignment: .leading)
        .border(Color.purple, width: 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//Shape 协议是自定义绘制中最基本的部分，它只要求一个方法，即给定一个 CGRect的绘制范围，返回某个 Path。
struct TriangleArrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            path.addArc(center: CGPoint(x: -rect.width / 5, y: rect.height / 2), radius: rect.width / 2, startAngle: .degrees(-45), endAngle: .degrees(45), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
            path.closeSubpath()
        }
    }
}

/**
 有时候，我们会想要在 View 里进行一些更精细的尺寸及布局计算，这需要获取一些 布局的数值信息:比如当前 View 可以使用的 height 或者 width 是多少，需不需要 考虑 iPhone X 系列的安全区域 (safe area) 等。SwiftUI 中，我们可以通过 GeometryReader 来读取 parent View 提供的这些信息。和 SwiftUI 里大部分类型一 样，GeometryReader 本身也是一个 View，它的初始化方法需要传入一个闭包，这 个闭包也是一个 ViewBuilder，并被用来构建被包装的 View。和其他常见 ViewBuilder 不同，这个闭包将提供一个 GeometryProxy 结构体:
 ```
 public struct GeometryProxy {
     public var size: CGSize { get }
     public subscript<T>(anchor: Anchor<T>) !" T { get } public var safeAreaInsets: EdgeInsets { get } public func frame(
           in coordinateSpace: CoordinateSpace
         ) !" CGRect
 }
 ```
 */
struct FlowRectangle: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Rectangle().fill(Color.red).frame(height: 0.3 * proxy.size.height)
                HStack(spacing: 0) {
                    Rectangle().fill(Color.green).frame(width: 0.4 * proxy.size.width)
                    VStack(spacing: 0) {
                        Rectangle().fill(Color.blue).frame(height: 0.4 * proxy.size.height)
                        Rectangle().fill(Color.yellow).frame(height: 0.3 * proxy.size.height)
                    }.frame(width: 0.6 * proxy.size.width)
                }
            }
        }
    }
}
