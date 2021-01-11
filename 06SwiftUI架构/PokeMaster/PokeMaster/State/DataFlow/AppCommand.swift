//
//  AppCommand.swift
//  PokeMaster
//
//  Created by 华惠友 on 2021/1/7.
//  Copyright © 2021 OneV's Den. All rights reserved.
//

import Foundation
import Combine

/**
 在上一节的用户登录的示例中，检查用户密码和设置 loginUser 属性这些操作都是以 同步方式立即完成的，但这显然和真实情况相去甚远。实际上，我们可能需要将用户的邮箱和密码通过网络请求发送给服务器，并由服务器完成用户验证，并把结果返 回给 app，这些都涉及到异步操作。
 对于一个异步操作，一般来说我们比较关注两个时间点。首先是异步操作开始的时 候，我们可能希望在此时显示像是 “正在加载” 的界面，让用户知道正在进行一项耗 时操作。另一个时间点是操作完成时，这时候我们可以使用异步操作的结果 (比如网 络请求返回的数据) 来更新界面。因此，一个异步操作一般会对应两个 State:一个 代表操作开始，app 进入等待状态;另一个代表操作结束，可以按照需要更新 UI。 Reducer 负责返回新的 State，对于像网络请求这种耗时的异步操作，我们不可能阻 塞线程去等待请求完成再返回新状态，因此，我们需要一种另外的方式来处理异步 操作，让它在一次请求中拥有两次更新状态的机会。
 
 
 在前面，我们已经多次重申过，Reducer 的唯一职责应该是计算新的 State，而发送 请求和接收响应，显然和返回新的 State 没什么关系，它们属于设置状态这一操作的 “副作用”。在我们的架构中我们使用 Command 来代表 “在设置状态的同时需要触发 一些其他操作” 这个语境。Reducer 在返回新的 State 的同时，还返回一个代表需要 进行何种副作用的 Command 值 (对应上一段中的第一个时间点)。Store 在接收到这 个 Command 后，开始进行额外操作，并在操作完成后发送一个新的 Action。这个 Action 中带有异步操作所获取到的数据。它将再次触发 Reducer 并返回新的 State， 继而完成异步操作结束时的 UI 更新 (对应上一段中的第二个时间点)。
 */


//在 Reducer 负责返回新的 State 的同时，我们还希望它同时返回一个 Command 来 表示 “需要执行的副作用”。
//这个协议定义了一个唯一的方法 execute(in:)，它是开始执行副作用的入口。参数 Store 则提供了一个执行后续操作的上下文，让我们可以在副作用执行完毕时，继续 发送新的 Action 来更改 app 状态。在 AppCommand 定义下方，我们创建一个遵守该协议的具体类型 LoginAppCommand，它使用 LoginRequest 发送一个登录请求， 并处理结果:
protocol AppCommand {
    func execute(in store: Store)
}

struct LoginAppCommand: AppCommand {
    let email: String
    let password: String
    
    func execute(in store: Store) {
        //创建一个 SubscriptionToken 值备用，它需要存活到订阅的异步事件结束。
        let token = SubscriptionToken()
        
        LoginRequest(email: email, password: password).publisher
            //LoginRequest.publisher 是我们刚才定义好的模拟登录操作的 Publisher，我 们使用 sink 进行订阅。
            .sink { (complete) in
                //当错误发生时，receiveCompletion 将会被调用，闭包的传入参数是一个描述 错误的 .failure 成员。使用 if case 我们可以在过滤出这个 case 的同时，将关 联的 error 值提取出来。在这里，我们需要通过向 store 发送 Action 来显示错 误。
                if case .failure(let error) = complete {
                    store.dispatch(.accountBehaviorDone(result: .failure(error)))
                }
                //调用 token 的 unseal 方法将 AnyCancellable 释放。在这里，unseal 中里将 cancellable 置为 nil 的操作其实并不是必须的，因为一旦 token 离开作用域 被释放后，它其中的 cancellable 也会被释放，从而导致订阅资源的释放。这 里的关键是利用闭包，让 token 本身存活到事件结束，以保证订阅本身不被取 消。
                token.unseal()
            } receiveValue: { (user) in
                //登录成功时我们可以收到 Publisher 发出的 User 值。类似上面，我们也需要 通过 Action 来改变 State。
                store.dispatch(.accountBehaviorDone(result: .success(user)))
            }.seal(in: token)//在 sink 订阅后，把返回的 AnyCancellable 存放到 token 里。
    }
    //对于内部含有异步操作，并使用 Combine 来处理的 AppCommand，我们都可以通 过类似的方式来维持订阅，这可以让我们以最小限度使用资源的同时，保持一个相 对干净的写法。Combine 框架内部为 AnyCancellable 准备了 store(in:) 方法，用来 将自身存储到一个 Array 或者 Set 中。我们在后面的章节会看到它们的例子，而这里 的 seal(in:) 正是借鉴了 Combine 的处理方式。
}

/**
 关于登录，我们还有最后一个问题需要处理:现在用户登录和 loginUser 的状态只在 内存中暂存。当我们重启 app 时，之前已登录的用户又将回到未登录的状态。想要 在 app session 之间维持登录状态，我们需要把 loginUser 进行持久化，也就是写到 硬盘上，你可以将它保存到 UserDefaults、Keychain 或者某个自定义文件中。
 对于 Reducer 来说，这又是一个和设置 State 无关的副作用。因此最 “标准” 的做法 是，我们定义一个 WriteUserAppCommand 的新 AppCommand 类型，在处理 .accountBehaviorDone 中用户正常登录时，除了设置 loginUser 以外，同时返回一 个 WriteUserAppCommand 实例作为需要执行的副作用。在这个副作用的 execute(in:) 中，完成对 loginUser 的持久化工作。下面是一种可能的实现方式:
 */
/**
 登录时的请求所对应的 LoginAppCommand，在异步行为结束后再次通过 Action 改 变了 State。而 WriteUserAppCommand 与它不同，它不会再去改变状态。我们将 这类不再改变状态的副作用称为 “纯副作用”。最正规的做法自然是对每个副作用都 定义自己的 AppCommand，不过，这类 “纯副作用” 在 app 中会很常见。对每个纯 副作用都去定义一个类型，将会导致我们的 app 中存在很多 AppCommand，它们往 往不会很复杂，但是却让人烦躁。
 
 在这个架构中，我们规定一个特例，那就是对于 “纯副作用”，我们可以考虑通过属 性的 didSet 来执行这个副作用，而跳过严格的 Command 流程。像是将 loginUser 写入磁盘或者从磁盘读出这样的任务，就非常符合这个情景。
 */
/**
struct WriteUserAppCommand: AppCommand {
    let user: User
    func execute(in store: Store) {
        try? FileHelper.writeJSON(user, to: .documentDirectory, fileName: "user.json")
    }
}
*/



//编译项目的话，Xcode 会给你一个警告:在 execute(in:) 里，我们并没有使用到通过 sink 订阅的 LoginRequest publisher 所返回的值。这个返回值是一个 AnyCancellable，在它被释放时，cancel() 会被自动调用，导致订阅取消。上面的代 码里发生的正是这一情况:因为我们没有存储这个值，它在创建后就立即被释放掉， 导致订阅取消。如果我们不想要这个异步操作在完成之前就被取消掉，就需要想办 法持有 sink 的返回值，直到异步操作完成。为了达到这一点，可以添加一个 SubscriptionToken 来持有 AnyCancellable:
class SubscriptionToken {
    var cancellable: AnyCancellable?
    func unseal() { cancellable = nil }
}

//AnyCancellable extension 上的 seal 会把当前的 AnyCancellable 值 “封印” 到 SubscriptionToken 中去
extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}

