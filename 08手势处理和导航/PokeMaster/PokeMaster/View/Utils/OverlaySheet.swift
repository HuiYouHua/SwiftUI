//
//  OverlaySheet.swift
//  PokeMaster
//
//  Created by 王 巍 on 2019/09/30.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import Foundation
import SwiftUI

struct OverlaySheet<Content: View>: View {
    
    private let isPresented: Binding<Bool>
    private let makeContent: () -> Content
    
    ///记录手势的移动
    //普通的 @State 和 @GestureState 最大的不同在于，当手势结束时， @GestureState 的值会被隐式地置为初始值。当这个特性正是你所需要的时候，它可以简化你的代码，但是如果你的状态值需要在手势结束后依然保持不 变，则应该使用 onChanged 的版本。
    @GestureState private var translation = CGPoint.zero
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.makeContent = content
    }
    
    var body: some View {
        VStack {
            Spacer()
            makeContent()
        }.offset(y: (isPresented.wrappedValue ? 0 : UIScreen.main.bounds.height) + max(0, translation.y))//当 isPresented 为 false 时，我们为 VStack 设置了 offset，让它处于屏幕外部。以 达到隐藏的目的。
        .animation(.interpolatingSpring(stiffness: 70, damping: 12))
        .edgesIgnoringSafeArea(.bottom)
        .gesture(panelDraggingGesture)
    }
    
    //SwiftUI 提供了三种对手势进行组合的方式，分别是代表手势需要顺次发生的 SequenceGesture、需要同时发生的 SimultaneousGesture 和只能有一个发 生的 ExclusiveGesture。
    //除了 @GestureState 外，你也可以使用普通的 @State 来暂存划动距 离。除了 updating(_:body:) 以外，你也可以通过 onChanged 来设定新的手 势状态
    var panelDraggingGesture: some Gesture {
        //使用 DragGesture 来监听用户的拖拽手势。除了使用这个不带任何参数的初 始化方法外，DragGesture 的 init 还支持设定最小侦测距离和要使用的座标系 等参数。对于我们的需求，直接使用默认值的初始化方法就可以了。
        DragGesture().updating($translation) { (current, state, _) in
            //在手势触发后，每次状态变更时 updating 都会被调用。updating 的尾随闭包 中第二个参数是一个标记为 inout 的待设定值。对这个值进行设置，SwiftUI 将可以通过 $translation 对 @GestureState 状态进行更新。这里我们在每次 手势状态更新后都记录了手势当前所处位置相对于起始位置的位移高度。
            state.y = current.translation.height
        }.onEnded { (state) in
            //在手势结束时，判断相对于原始位置，手势是否下划超过了 250 point。如果 下划距离足够，则将 isPresented 的包装值 (wrappedValue) 设为 false，这 会关闭当前的弹出界面。
            if state.translation.height > 250 {
                self.isPresented.wrappedValue = false
            }
        }
    }
}

extension View {
    func overlaySheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        overlay(OverlaySheet(isPresented: isPresented, content: content))
    }
}
