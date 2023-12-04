//
//  File.swift
//  
//
//  Created by Nick Kibysh on 03/11/2023.
//

import Foundation

class Node<T> {
    var value: T
    var next: Node?

    init(value: T) {
        self.value = value
    }
}

class Queue<T> {
    private var front: Node<T>?
    private var rear: Node<T>?
    private let accessQueue = DispatchQueue(label: "com.ble-library.threadSafeQueue")

    var isEmpty: Bool {
        return front == nil
    }

    // Enqueue operation to add an element to the rear of the queue
    func enqueue(_ value: T) {
        accessQueue.sync {
            let newNode = Node(value: value)
            if isEmpty {
                front = newNode
                rear = newNode
            } else {
                rear?.next = newNode
                rear = newNode
            }
        }
    }

    // Dequeue operation to remove and return the element from the front of the queue
    func dequeue() -> T? {
        var element: T?
        accessQueue.sync {
            if let currentFront = front {
                front = currentFront.next
                if front == nil {
                    rear = nil
                }
                element = currentFront.value
            } else {
                element = nil
            }
        }
        return element
    }

    // Peek operation to get the value at the front of the queue without removing it
    func peek() -> T? {
        return front?.value
    }
}
/*
struct Queue<T> {
    private var queue = [T]()
    private let accessQueue = DispatchQueue(label: "com.ble-library.threadSafeQueue")

    mutating func enqueue(_ element: T) {
        accessQueue.sync {
            queue.append(element)
        }
    }

    mutating func dequeue() -> T? {
        var element: T?
        accessQueue.sync {
            if !queue.isEmpty {
                element = queue.removeFirst()
            }
        }
        return element
    }
    
    var head: T? {
        var element: T?
        accessQueue.sync {
            element = queue.first
        }
        return element
    }

    var isEmpty: Bool {
        var empty = false
        accessQueue.sync {
            empty = queue.isEmpty
        }
        return empty
    }

    var count: Int {
        var queueCount = 0
        accessQueue.sync {
            queueCount = queue.count
        }
        return queueCount
    }
}
*/
