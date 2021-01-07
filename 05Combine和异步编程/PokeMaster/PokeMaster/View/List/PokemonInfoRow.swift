//
//  PokemonInfoRow.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct PokemonInfoRow: View {
    
    let model: PokemonViewModel
    ///控制 cell 的展开状态
    let expand: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image("Pokemon-\(model.id)")
                    .resizable() //SwiftUI 中图片绘制与 frame 是无关的，而只会遵从图片本身的 大小。如果我们想要图片可以按照所在的 frame 缩放，需要添加 resizable()。
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)//图片的原始尺寸比例和使用 frame(width:height:) 所设定的长宽比例可能有所 不同。aspectRatio 让图片能够保持原始比例。不过在本例中，缩放前的图片 长宽比也是 1:1，所以预览中不会有什么变化。
                    .shadow(radius: 4)//为图片增加一些阴影的视觉效果。
                Spacer()
                VStack(alignment: .trailing) {
                    Text(model.name)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    Text(model.nameEN)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 12)
            Spacer()//在两个 HStack 之间插入了一个 Spacer。这是为了让宝可梦图片名字的 HStack 相对固定，这样在之后的展开/收缩动画中它不会任意移动。其实通过 精确计算 frame 高度也可以达到同样的效果，不过加入这个 Spacer 让我们可 以用灵活的方式应对今后 cell 高度变化所带来的变动。
            HStack(spacing: expand ? 20 : -30) { //按照设计，我们需要在按钮之间添加一个间距。非展开状态下，将按钮的 HStack 间距设定为 -30。因为在非展开时我们直接 隐藏了按钮行，所以暂时看不出效果，这是为了之后的动画所做的设定。
                Spacer()
                Button(action: { print("fav") }) {
                    Image(systemName: "star")//使用 Image(systemName: "star") 来加载系统内置的 SF Symbol
                        .modifier(ToolButtonModifier())
                }
                Button(action: { print("panel") }) {
                    Image(systemName: "chart.bar")
                        .modifier(ToolButtonModifier())
                }
                Button(action: { print("web") }) {
                    Image(systemName: "info.circle")
                        .modifier(ToolButtonModifier())
                }
            }.padding(.bottom, 12)//在底部添加了 padding。
            .opacity(expand ? 1.0 : 0.0)//通过设定透明度来隐藏按钮。
            .frame(maxHeight: expand ? .infinity : 0)//当 expanded 为 true 时，设定按钮的 HStack 填满剩余高度;false 时，将frame 高度设为 0，它将不占用外部的布局的高度。
        }
        .frame(maxHeight: expand ? 120 : 80)//当非展开状态时，将 cell 高度设为 80。
        .padding(.leading, 23)
        .padding(.trailing, 15)
        .background(
            ZStack {//叠起来: 为了下面的两个矩形z轴叠加一起 将轮廓和渐变背景用 ZStack 堆叠起来
                RoundedRectangle(cornerRadius: 20)//边框
                    .stroke(model.color, style: StrokeStyle(lineWidth: 4))
                RoundedRectangle(cornerRadius: 20)//创建渐变
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, model.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        )
        .padding(.horizontal) //水平方向padding
//        animation(.default)//隐式动画隐式. 动画的作用范围很大:只要这个 View 甚至是它的子 View 上的可动画属性发生 变化，这个动画就将适用。
//        .animation(
//            Animation
//                .linear(duration: 0.5)
//                .delay(0.2)
//                .repeatForever(autoreverses: true)
//        )
    }
}

/**
 注意到，三个 Button 的设置部分是完全重复的。我们可以像之前章节那样把重复部 分提取出来，形成一个新的 View 类型。不过，我们还有另一种方法，来避免这种对 View 的重复设置，那就是创建自定义的 ViewModifier。
 ViewModifier 是 SwiftUI 提供的一个协议，它只有一个要求实现的方法
 
 我们的示例 app 相对简单，ViewModifier 可能没有太多用武之地。特别是本例中， Button 们都具有统一的行为和外观，所以使用新建类型的方式可能更好。不过，由 于 ViewModifier 可以跨越页面并作用在任意 View 上，因此在大型项目中，合理使 用 ViewModifier 来减少重复和维护难度会是很常见的做法。
 */
struct ToolButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 25))//可以使用 .font 来控制显示的大小。
            .foregroundColor(.white)
            .frame(width: 30, height: 30)//.font(.system(size: 25)) 虽然可以控制图片的显示尺寸，但是它并不会改变 Image 本身的 frame。默认情况下的 frame.size 非常小，这会使按钮的可点 击范围过小，因此我们使用 .frame(width:height:) 来指定尺寸。因为加载后 的 SF Symbol 是 Image，配合 frame 使用上面处理图像时提到的 resizable 和 padding 来指定显示范围和可点击范围也是可以的，但直接设置 font 和 frame 会更简单一些。
    }
}
