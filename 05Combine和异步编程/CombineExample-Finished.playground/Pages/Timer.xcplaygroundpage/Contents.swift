import Combine
import Foundation

//interval，runLoop 和 mode 参数分别定义了 Timer 事件的间隔秒数，计时所使用 RunLoop 和相应的模式等。比如我们想要在 RunLoop.main 上创建一个每隔一秒发 送一次事件的 Timer
//如果我们检查这个返回值的类型，会发现 Timer.TimerPublisher 是一个满足 ConnectablePublisher 的类型。ConnectablePublisher 不同于普通的 Publisher， 你需要明确地调用 connect() 方法，它才会开始发送事件
let timer = Timer.publish(every: 1, on: .main, in: .default)
let temp = check("Timer Connected") {
    timer
}
//一个显而易见的问题是，既然我们需要调用 connect() 才能让事件开始发生，那当我 们不再关心这个事件流的时候，是不是应该本着资源使用的 “谁创建，谁释放” 的原 则，让这个事件流停止发送呢?答案是肯定的:connect() 会返回一个 Cancellable 值，我们需要在合适的时候调用 cancel() 来停止事件流并释放资源。同样地，对于 订阅来说，大多数情况下我们也需要及时取消，以保证内存不发生泄漏。

//对 于 普 通 的Publisher， 当Failure是Never时， 就 可 以 使 用 makeConnectable() 将它包装为一个 ConnectablePublisher。这会使得该 Publisher 在等到连接 (调用 connect()) 后才开始执行和发布事件。在某些情况下，如果我们希望延迟及控制 Publisher 的开始时间，可以使用这个方 法。
//对 ConnectablePublisher 的 对 象 施 加 autoconnect() 的 话， 可 以 让 这 个 ConnectablePublisher “恢复” 为被订阅时自动连接。
timer.connect()

