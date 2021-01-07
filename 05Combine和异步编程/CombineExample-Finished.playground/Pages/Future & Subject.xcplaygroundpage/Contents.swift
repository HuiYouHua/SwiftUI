import Combine
import Foundation

func loadPage(
    url: URL,
    handler: @escaping (Data?, URLResponse?, Error?) -> Void)
{
    URLSession.shared.dataTask(with: url) {
        data, response, error in
        handler(data, response, error)
    }.resume()
}

//如果我们希望订阅操作和值的发布是异步行为，不在同一时间发生的话，可以使用 Future。Future 提供了一种方式，可以让我们创建一个接受未来的事件的 Publisher
//但是要注意，Future 只能为我们提供一次性 Publisher:对于提供的 promise，你只 有两种选择:发送一个值并让 Publisher 正常结束，或者发送一个错误。因此， Future 只适用于那些必然会产生事件结果，且至多只会产生一个结果的场景。比如 刚才看到的网络请求:它要么成功并返回数据及响应，要么直接失败并给出 URLError。一个 dataTask 的网络请求不会永远不发送任何事件，也不会产生多次的 响应，用 Future 进行包装恰得其所。如果你的异步 API 有可能不发送任何一个值， 而是可能发布两个或更多的值的话，你会需要一个更加一般性的 Publisher 类型来把 指令式程序转换为响应式程序，这个类型就是 Subject。
let future = check("Future") {
    Future<(Data, URLResponse), Error> { promise in
        loadPage(url: URL(string: "https://example.com")!) {
            data, response, error in
            if let data = data, let response = response {
                promise(.success((data, response)))
            } else {
                promise(.failure(error!))
            }
        }
    }
}

let subject = PassthroughSubject<Date, Never>()
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    subject.send(Date())
}

let timer = check("Timer") {
    subject
}
