//
//  File.swift
//
//
//  Created by Nick Kibysh on 03/11/2023.
//

import Foundation

struct Queue<T> {
	private var queue = [T]()
	private let accessQueue = DispatchQueue(label: "com.example.threadSafeQueue")

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
