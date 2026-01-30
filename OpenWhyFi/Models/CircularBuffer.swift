import Foundation

struct CircularBuffer<T> {
    private var storage: [T] = []
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
        storage.reserveCapacity(capacity)
    }

    mutating func append(_ element: T) {
        if storage.count >= capacity {
            storage.removeFirst()
        }
        storage.append(element)
    }

    var elements: [T] {
        storage
    }

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    var last: T? {
        storage.last
    }

    mutating func clear() {
        storage.removeAll(keepingCapacity: true)
    }
}
