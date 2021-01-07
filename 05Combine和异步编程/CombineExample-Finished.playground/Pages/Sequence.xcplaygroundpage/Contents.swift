import Combine

check("Sequence") {
    Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
}

check("Array") {
    //为了方便使用，Sequence 提供了一个辅助属性来从一个序列中获取 Publisher。上 面的代码可以等效写为
    [1, 2, 3].publisher
}

check("Map") {
    [1,2,3]
        .publisher
        .map { $0 * 2 }
}

check("Map Just") {
    Just(5)
        .map { $0 * 2 }
}

[1,2,3,4,5].reduce(0, +)

check("Reduce") {
    [1,2,3,4,5].publisher.reduce(0, +)
}

[1,2,3,4,5].scan(0, +)

check("Scan") {
    [1,2,3,4,5].publisher.scan(0, +)
}

check("Compact Map") {
    //将 map 结果中那些 nil 的元素去除掉，这个操作通常会 “压缩” 结果，让其中的元素数减少
    ["1", "2", "3", "cat", "5"]
        .publisher
        .compactMap { Int($0) }
}

check("Compact Map By Filter") {
    //与上面等效
    ["1", "2", "3", "cat", "5"]
        .publisher
        .map { Int($0) }
        .filter { $0 != nil }
        .map { $0! }
}

check("Flat Map 1") {
    [[1, 2, 3], ["a", "b", "c"]]
        .publisher
        .flatMap {
            $0.publisher
        }
}

check("Flat Map 2") {
    ["A", "B", "C"]
        .publisher
        .flatMap { letter in
            [1, 2, 3]
                .publisher
                .map { "\(letter)\($0)" }
        }
}

check("Remove Duplicates") {
    //移除连续出现的重复事件值
    ["S", "Sw", "Sw", "Sw", "Swi",
     "Swif", "Swift", "Swift", "Swif"]
        .publisher
        .removeDuplicates()
}
