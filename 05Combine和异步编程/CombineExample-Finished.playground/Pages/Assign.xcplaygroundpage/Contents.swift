import Combine
import SwiftUI

class Clock {
    var timeString: String = "--:--:--" {
        didSet { print("\(timeString)") }
    }
}

let clock = Clock()

let formatter = DateFormatter()
formatter.timeStyle = .medium

let timer = Timer.publish(every: 1, on: .main, in: .default)
//除了 Subscribers.Sink 以外，Combine 里还有另一个内建的 Subscriber: Subscribers.Assign，它可以用来将 Publisher 的输出值通过 key path 绑定到一个 对象的属性上去。在 SwiftUI 中，这种值通常会是 ObservableObject 中的属性值， 它进一步会被用来驱动 View 的更新
//我们使用了预先定义的 formatter 通过 map 将 Date 变形为我们需要的字符串表示 形式，然后用 assign 将这个字符串绑定给了 clock 的 timeString。注意 assign 所接 受的第一个参数的类型为 ReferenceWritableKeyPath，也就是说，只有 class 上用 var 声明的属性可以通过 assign 来直接赋值。
//assign 的另一个 “限制” 是，上游 Publisher 的 Failure 的类型必须是 Never。如果 上游 Publisher 可能会发生错误，我们则必须先对它进行处理，比如使用 replaceError 或者 catch 来把错误在绑定之前就 “消化” 掉。
var token = timer
    .map { formatter.string(from: $0) }
    .assign(to: \.timeString, on: clock)



timer.connect()
