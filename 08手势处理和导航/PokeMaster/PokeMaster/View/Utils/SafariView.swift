//
//  SafariView.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/11.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI
import SafariServices

/**
 SFSafariViewController 是一个 UIViewController 的子类，我们已经看到过如何使 用 UIViewRepresentable 来将一个 UIView 类型包装成 SwiftUI.View。对于 UIViewController 来说，SwiftUI 提供了一个相似的协议来帮助我们把任意的 UIViewController 桥接为 SwiftUI.View，那就是 UIViewControllerRepresentable。 我们先来创建一个接受 url 并展示它的 SafariView:
 */
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onFinished: () -> Void
    
    /**
     SFSafariViewController 还提供了一个默认的 “完成” 按钮，现在点击 Done 时，并不会关闭这个页面。我们需要一种方法获取到该按钮的点击事件，并主动将网 页弹出导航栈。在 SFSafariViewController 中，完成按钮的点击是通过 SFSafariViewControllerDelegate 中的 safariViewControllerDidFinish(_:) 方法传 递的。想要在 SafariView 获取它，需要我们为 SFSafariViewController 设置 delegate。这可以通过在 SafariView 里传递一个 context 并使用其中的 coordinator 对象来做到。这也是在 SwiftUI 中处理 UIKit 相关的 delegate 的一般性的方式。
     */
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.onFinished()
        }
    }
    
    /**
     makeCoordinator 是 UIViewControllerRepresentable 协议定义的一个方法。 你可以在这里创建并返回一个任意类型的对象。这个对象在之后相关调用中都 会被设置在 context.coordinator 属性里。使用这种方法，SwiftUI 让你可以在 View 的不同时期间传递任意数据。本例中，我们所传递的是被作为 delegate 使用的 Coordinator。[controller.delegate = context.coordinator]
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        ///最后，将生成的 coordinator 设为 SFSafariViewController 的 delegate。
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
}
