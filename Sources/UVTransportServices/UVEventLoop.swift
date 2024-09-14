import Clibuv
import Foundation
import NIOCore

public final class UVEventLoop: EventLoop {
    private let thread = UVExecutionThread()

    init() {
        thread.start()
    }

    public var inEventLoop: Bool { Thread.current == thread }

    public func execute(_ task: @escaping UVTask) {
        thread.submitBlocking(task)
    }

    public func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping @Sendable () throws -> T) -> Scheduled<T> {
        let p: EventLoopPromise<T> = makePromise()
        let scheduledTask: UVTask = {
            do {
                try p.succeed(task())
            } catch {
                p.fail(error)
            }
        }

        thread.submitBlockingAt(scheduledTask, timeout: deadline.uptimeNanoseconds / 1_000_000)

        return .init(promise: p, cancellationTask: {})
    }

    public func scheduleTask<T>(in time: TimeAmount, _ task: @escaping @Sendable () throws -> T) -> Scheduled<T> {
        let p: EventLoopPromise<T> = makePromise()
        let scheduledTask: UVTask = {
            do {
                try p.succeed(task())
            } catch {
                p.fail(error)
            }
        }

        thread.submitBlockingAfter(scheduledTask, timeout: UInt64(time.nanoseconds) / 1_000_000)

        return .init(promise: p, cancellationTask: {})
    }

    public func shutdownGracefully(queue _: DispatchQueue, _ callback: @escaping @Sendable ((any Error)?) -> Void) {
        stop()
        thread.join()
        callback(nil)
    }

    public func stop() {
        thread.cancel()
    }

    public func join() {
        thread.join()
    }
}
