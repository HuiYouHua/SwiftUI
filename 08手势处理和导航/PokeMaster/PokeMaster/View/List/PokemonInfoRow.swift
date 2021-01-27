//
//  PokemonInfoRow.swift
//  PokeMaster
//
//  Created by 王 巍 on 2019/08/29.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct PokemonInfoRow: View {

    @EnvironmentObject var store: Store
//    @State var isSFViewActive = false
    let model: PokemonViewModel
    let expanded: Bool

    var body: some View {
        VStack {
            HStack {
                Image("Pokemon-\(model.id)")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 4)
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
            Spacer()
            HStack(spacing: expanded ? 20 : -30) {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "star")
                        .modifier(ToolButtonModifier())
                }
                Button(action: {
                    let target = !self.store.appState.pokemonList.selectionState.panelPresented
                    self.store.dispatch(.togglePanelPresenting(presenting: target))
                }) {
                    Image(systemName: "chart.bar")
                        .modifier(ToolButtonModifier())
                }
//                Button(action: {}) {
//                    Image(systemName: "info.circle")
//                        .modifier(ToolButtonModifier())
//                }
                //注意，NavigationLink 只在当前 View 处于 NavigationView 中才有效。在我 们的例子中，NavigationView 被定义在 PokemonRootView 里。
                NavigationLink(
                    destination: SafariView(url: model.detailPageURL) {
                        ///在 SafariView 的 onFinished 调用后，把属于当前 PokemonInfoRow 的 isSFViewActive 设为 false
                        //不过，上面这样用 @State 的方式，不太符合示例 app 中的架构模式: isSFViewActive 控制的不仅仅是自身 View 中临时状态，而是影响了整个 app UI 结 构的状态。简单地使用这样的 @State，破坏了 model 和 view 的对应关系。我们会 想办法将这个状态放到 AppState 里，用 AppAction 来修改状态并驱动 UI。
//                        self.isSFViewActive = false
                        self.store.dispatch(.closeSafariView)
                    }.navigationBarTitle(Text(model.name), displayMode: .inline),
                    isActive: expanded ? $store.appState.pokemonList.isSFViewActive : .constant(false),
                    label: {
                        Image(systemName: "info.circle").modifier(ToolButtonModifier())
                    })
            }
            .padding(.bottom, 12)
            .opacity(expanded ? 1.0 : 0.0)
            .frame(maxHeight: expanded ? .infinity : 0)
        }
        .frame(height: expanded ? 120 : 80)
        .padding(.leading, 23)
        .padding(.trailing, 15)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(model.color, style: StrokeStyle(lineWidth: 4))
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, model.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        )
        .padding(.horizontal)
    }
}

struct ToolButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 25))
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
    }
}

struct PokemonInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PokemonInfoRow(model: .sample(id: 1), expanded: false)
            PokemonInfoRow(model: .sample(id: 21), expanded: true)
            PokemonInfoRow(model: .sample(id: 25), expanded: false)
        }
    }
}
