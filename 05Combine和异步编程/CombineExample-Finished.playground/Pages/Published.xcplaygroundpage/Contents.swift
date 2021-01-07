import Combine
import Foundation

//我们在前面的章节中已经看到过 @State 和 @ObservedObject 这样的 Property Wrapper，它们对属性值的 getter 和 setter 进行包装，来实现一些常见功能。类似 地，Combine 中存在 @Published 封装，用来把一个 class 的属性值转变为 Publisher。它同时提供了值的存储和对外的 Publisher (通过投影符号 $ 获取)。在被 订阅时，当前值也会被发送给订阅者，它的底层其实就是一个 CurrentValueSubject
class Wrapper {
    @Published var text: String = "hoho"
}

var wrapper = Wrapper()
check("Published") {
    wrapper.$text
}

wrapper.text = "123"
wrapper.text = "abc"
