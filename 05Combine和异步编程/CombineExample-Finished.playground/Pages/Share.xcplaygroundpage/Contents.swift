import Combine
import Foundation

class LoadingUI {
    var isSuccess: Bool = false
    var text: String = ""
}

struct Response: Decodable {
    struct Foo: Decodable {
        let foo: String
    }
    let args: Foo?
}

//在变形的时候，负责网络请求的 Publisher 将被复制一份。这样一来，最后使用 assign 操作 isSuccess 和 latestText 时，最终订阅的是两个不同的 Publisher，因此网络请求也 发生了两次。
//想要改变这个行为，可以将值语义的 dataTaskPublisher 转变为引用语义 (reference semantics)。我们只要在创建 dataTaskPublisher 后加上 share() 即可。 通过 share() 操作，原来的 Publisher 将被包装在 class 内，对它的进一步变形也会 适用引用语义

//对于多个 Subscriber 对应一个 Publisher 的情况，如果我们不想让订阅行为反复发 生 (比如上例中订阅时会发生网络请求)，而是想要共享这个 Publisher 的话，使用 share() 将它转变为引用类型的 class。
let dataTaskPublisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://httpbin.org/get?foo=bar")!)
    .share()

let isSuccess = dataTaskPublisher
    .map { data, response -> Bool in
        guard let httpRes = response as? HTTPURLResponse else {
            return false
        }
        return httpRes.statusCode == 200
    }
    .replaceError(with: false)

let latestText = dataTaskPublisher
    .map { data, _ in data }
    .decode(type: Response.self, decoder: JSONDecoder())
    .compactMap { $0.args?.foo }
    .replaceError(with: "")

let ui = LoadingUI()
var token1 = isSuccess.assign(to: \.isSuccess, on: ui)
var token2 = latestText.assign(to: \.text, on: ui)

