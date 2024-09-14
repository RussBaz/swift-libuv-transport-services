import Dispatch
import Foundation
import NIOCore

public final class UVEventLoopGroup: EventLoopGroup {
    private let eventLoops: [UVEventLoop]
    private let indexLock = NSLock()
    private var loopIndex: [UVEventLoop].Index

    public init(loopCount: Int = 1) {
        let loopCount = max(loopCount, 1)
        var loops: [UVEventLoop] = []
        for _ in 0 ..< loopCount {
            loops.append(.init())
        }

        eventLoops = loops
        loopIndex = loops.startIndex
    }

    public func next() -> any EventLoop {
        indexLock.lock()
        defer { indexLock.unlock() }
        loopIndex = eventLoops.index(after: loopIndex)
        if loopIndex == eventLoops.endIndex {
            loopIndex = eventLoops.startIndex
        }

        return eventLoops[loopIndex]
    }

    public func makeIterator() -> EventLoopIterator {
        .init(eventLoops)
    }

    public func shutdownGracefully(queue _: DispatchQueue, _ callback: @escaping @Sendable ((any Error)?) -> Void) {
        for loop in eventLoops {
            loop.stop()
        }

        for loop in eventLoops {
            loop.join()
        }

        callback(nil)
    }
}
