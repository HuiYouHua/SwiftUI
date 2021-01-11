//
//  ActivityIndicatorView.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/11.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    
    let style: UIActivityIndicatorView.Style
    
    @Binding
    var isAnimating: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
