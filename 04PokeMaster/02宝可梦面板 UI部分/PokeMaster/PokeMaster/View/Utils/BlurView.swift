//
//  BlurView.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/6.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

/**
 实现背景模糊的效果.但不幸的是，当前 SwiftUI 中并没有直接提供类似的功能。 在本书写作时，SwiftUI 还处在非常初期的阶段，难免会出现无法实现的效果或者在 SwiftUI 中无法绕过的问题。遇到这样的情况时，最简单的解决方案是把 UIKit 中已 有的部分进行封装，提供给 SwiftUI 使用
 SwiftUI 中的 UIViewRepresentable 协议提供了封装 UIView 的功能。这个协议要求 我们实现两个方法:makeUIView 和 updateUIView
 */
struct BlurView: UIViewRepresentable {
    
    //为了更好的泛用性，我们将控制模糊样式的 UIBlurEffect.Style 作为成员变量 使用。这样在 SwiftUI 层可以通过控制 style 来决定需要什么样的模糊效果。
    let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style) {
        print("Init")
        self.style = style
    }
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> some UIView {
        print("makeUIView")
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        //在 UIView 布局方面，UIKit 中的 Auto Layout 依然有效，按照传统的方式将 UIVisualEffectView 添加到上层 view 上即可。最外层返回的 view 的布局将 由 SwiftUI 接手。
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor
              .constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor
              .constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    
    //对于模糊背景的需求，我们不需要关心更新的问题。所以把 updateUIView 留 空。
    func updateUIView(_ uiView: UIViewType, context: Context) {
        for v in uiView.subviews {
            if let blurView = v as? UIVisualEffectView {
                blurView.effect = UIBlurEffect(style: style)
            }
        }
        print("updateUIView")
    }
}

//为了使用起来方便，我们可以创建一个 View 的 extension，把 BlurView 的使用包装 起来
extension View {
    func blurBackground(style: UIBlurEffect.Style) -> some View {
        ZStack {
            BlurView(style: style)
            self
        }
    }
}
