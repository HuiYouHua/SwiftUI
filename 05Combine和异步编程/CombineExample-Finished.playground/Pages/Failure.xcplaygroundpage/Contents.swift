import Combine
import Foundation
//错误处理
enum MyError: Error {
    case myError
}

check("Fail") {
    Fail<Int, SampleError>(error: .sampleError)
}

check("Map Error") {
    // Subscriber 在订阅上游 Publisher 时，不仅需要保证 Publisher.Output 的类型和 Subscriber.Input 的类型一致，也要保证两者所接受的 Failure 也具有相同类型。
    //我们可以通过使用 mapError 来将 Publisher 的 Failure 转换成 Subscriber 所需要的 Failure 类型
    //map 对 Output 进行转换，mapError 对 Failure 进行转换
    Fail<Int, SampleError>(error: .sampleError)
        .mapError { _ in MyError.myError }
}

//抛出错误
check("Throw") {
    //除了 tryMap 以外，Combine 中还有很多类似的以 try 开头的 Operator，比如 tryScan，tryFilter，tryReduce 等等。当你有需求在数据转换或者处理时，将事件 流以错误进行终止，都可以使用对应操作的 try 版本来进行抛出，并在订阅者一侧接 收到对应的错误事件。
    ["1", "2", "Swift", "4"].publisher
        .tryMap { s -> Int in
            guard let value = Int(s) else {
                throw MyError.myError
            }
            return value
        }
}

//从错误中恢复
check("Replace Error") {
    //在 Combine 里，有一些 Operator 是专门帮助事件流从错误中恢复的，最简单的是 replaceError，它会把错误替换成一个给定的值，并且立即发送 finished 事件
    ["1", "2", "Swift", "4"].publisher
        .tryMap { s -> Int in
            guard let value = Int(s) else {
                throw MyError.myError
            }
            return value
        }
        .replaceError(with: -1)
}

check("Catch with Just") {
    //replaceError 在错误时接受单个值，另一个操作 catch 则略有不同，它接受的是一 个新的 Publisher，当上游 Publisher 发生错误时，catch 操作会使用新的 Publisher 来把原来的 Publisher 替换掉
    ["1", "2", "Swift", "4"].publisher
        .tryMap { s -> Int in
            guard let value = Int(s) else {
                throw MyError.myError
            }
            return value
        }
        .catch { _ in Just(-1) }
}

check("Catch with Another Publisher") {
    //看上去输出和上面的 replaceError 没有区别，但是记住在 catch 的闭包中，我们返 回的是 Just(-1) 这个 Publisher，而不仅仅只是 Int 的 -1。实际上，任何满足 Output == Int 和 Failure == Never 的 Publisher 都可以作为 catch 的闭包被返回， 并替代原来的 Publisher:
    ["1", "2", "Swift", "4"].publisher
        .tryMap { s -> Int in
            guard let value = Int(s) else {
                throw MyError.myError
            }
            return value
        }
        .catch { _ in [-1, -2, -3].publisher }
}

check("Catch and Continue") {
    //当错误发生后，原本的 Publisher 事件流将被中断，取而代之，则是 由 catch 所提供的事件流继续向后续的 Operator 及 Subscriber 发送事件。原来 Publisher 中的最后一个元素 “4”，将没有机会到达。
    
    //如果我们将 (由 ["1", "2", "Swift", "4"] 构成的) 原 Publisher 看作是用户输入，将结 果的 Int 看作是最后输出，那么像上面那样的方式使用 replaceError 或者 catch 的 话，一旦用户输入了不能转为 Int 的非法值 (如 “Swift”)，整个结果将永远停在我们 给定的默认恢复值上，接下来的任意用户输入都将被完全忽略。这往往不是我们想 要的结果，一般情况下，我们会想要后续的用户输入也能继续驱动输出，这时候我们 可以靠组合一些 Operator 来完成所需的逻辑
    ["1", "2", "Swift", "4"].publisher
        .flatMap { s in return
            Just(s)
            .tryMap { s -> Int in
                guard let value = Int(s) else {
                    throw MyError.myError
                }
                return value
            }
            .catch { _ in Just(-1) } }
    
    
}

check("Catch and Continue") {
    ["1", "2", "Swift", "4"].publisher
        .print("[Original]")
        .flatMap { s in
            return Just(s)
                .tryMap { s -> Int in
                    guard let value = Int(s) else {
                        throw MyError.myError
                    }
                    return value
                }
                .print("[TryMap]")
                .catch { _ in
                    Just(-1).print("[Just]") }
                .print("[Catch]")
        }
}
