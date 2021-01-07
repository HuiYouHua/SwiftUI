import Combine
import Foundation

struct Response: Decodable {
    struct Foo: Decodable {
        let foo: String
    }
    let args: Foo?
}

let input = PassthroughSubject<String, Error>()

let session = check("URL Session") {
    input.flatMap { text in
        //URLSession 的 dataTaskPublisher(for:) 方法可以直接返回一个 Publisher，它会在 网络请求成功时发布一个值为 (Response, Data) 的事件，请求过程失败时，发送类 型为 URLError 的错误。
        //在 dataTaskPublisher 发送一个新的事件值时，我们将其中的 Data 通过 map 的方 式提取出来，并交给 decode 这个 Operator 进行处理。decode 要求上游 Publisher 的 Output 类型是 Data，它会使用参数中接受的 decoder (本例中是 JSONDecoder()) 来对上游数据进行解析，生成对应类型 (本例中是 Response) 的实 例，并作为新的 Publisher 事件发布出去。
        URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://httpbin.org/get?foo=\(text)")!)
            .map { data, _ in data }
            .decode(type: Response.self, decoder: JSONDecoder())
            .compactMap { $0.args?.foo }
    }
}

input.send("hello")
input.send("world")
input.send(completion: .finished)

