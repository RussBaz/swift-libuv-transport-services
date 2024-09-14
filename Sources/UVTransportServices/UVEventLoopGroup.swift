import Dispatch
import NIOConcurrencyHelpers
import NIOCore

public final class UVEventLoopGroup: EventLoopGroup {
    private let eventLoops: [UVEventLoop]
    private let loopIndex: NIOLockedValueBox<[UVEventLoop].Index>

    public init(loopCount: Int = 1) {
        let loopCount = max(loopCount, 1)
        var loops: [UVEventLoop] = []
        for _ in 0 ..< loopCount {
            loops.append(.init())
        }

        eventLoops = loops
        loopIndex = NIOLockedValueBox(loops.startIndex)
    }

    public func next() -> any EventLoop {
        loopIndex.withLockedValue {
            $0 = eventLoops.index(after: $0)
            if $0 == eventLoops.endIndex {
                $0 = eventLoops.startIndex
            }
            return eventLoops[$0]
        }
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
