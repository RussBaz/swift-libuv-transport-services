import Clibuv

public typealias UVTask = @Sendable () -> Void
public typealias UVCheckTimeCallback = @Sendable (UInt64) -> Void
typealias UVTaskCallback = @Sendable (_ status: UVTaskStatus) -> Void

enum UVTaskStatus {
    case waiting
    case running
    case finished
    case cancelled
    case failed
}

enum UVTaskType {
    case blocking(task: UVTask)
    case threaded(task: UVTask, callback: UVTaskCallback)
    case timeNow(callback: UVCheckTimeCallback)
    case scheduleBlockingOnceAfter(task: UVTask, timeout: UInt64)
    case scheduleBlockingOnceAt(task: UVTask, timeout: UInt64)
    case stop
}
