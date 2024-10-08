import Clibuv
import Foundation

private func handleScheduledJob(_ req: UnsafeMutablePointer<uv_timer_t>?) {
    guard let req else { return }
    let timer = req.pointee.data.load(as: UVTimer.self)

    print("Running a scheduled task")
    timer.run()
}

private func closeScheduledJob(_ req: UnsafeMutablePointer<uv_handle_t>?) {
    guard let req else {
        print("Having issues closing the jobs handler")
        return
    }

    let timer = req.pointee.data.load(as: UVTimer.self)

    print("Closing the scheduled task handler")

    timer.delete()
}

final class UVScheduledManager {
    private let loop: UnsafeMutablePointer<uv_loop_t>
    private var timers: [UVTimer] = []

    init(loop: UnsafeMutablePointer<uv_loop_t>) {
        self.loop = loop
    }

    /// Schedule a task to run after a 'timeout' in milliseconds
    func submit(_ task: consuming @escaping UVTask, in timeout: UInt64) {
        let timer = UVTimer(manager: self, timeout: timeout, task: task)
        timers.append(timer)
        let i = timers.index(before: timers.endIndex)
        UVTimer.start(&timers[i], on: loop)
    }

    /// Schedule a task to run once the loop timer passes a 'timeout' in milliseconds
    func submit(_ task: consuming @escaping UVTask, at timeout: UInt64) {
        let time = uv_now(loop)
        if timeout > time {
            submit(task, in: timeout - time)
        } else {
            submit(task, in: 0)
        }
    }

    func removeTimer(with id: UUID) {
        let i = timers.firstIndex(where: { $0.key == id })
        guard let i else { return }
        timers.remove(at: i)
    }

    func timeNow(callback: @escaping UVCheckTimeCallback) {
        let time = uv_now(loop)
        callback(time)
    }
}

private final class UVTimer {
    let key: UUID
    private var value: uv_timer_t
    private var manager: UVScheduledManager
    private let task: UVTask
    private let timeout: UInt64

    init(manager: UVScheduledManager, timeout: UInt64, task: @escaping UVTask) {
        key = UUID()
        value = uv_timer_t()
        self.manager = manager
        self.task = task
        self.timeout = timeout
    }

    func run() {
        task()
        stop()
        print("finished running scheduled task")
    }

    func stop() {
        uv_timer_stop(&value)
        uv_close(castToBaseHandler(&value), closeScheduledJob(_:))
    }

    fileprivate func delete() {
        manager.removeTimer(with: key)
    }

    static func start(_ timer: inout UVTimer, on loop: UnsafeMutablePointer<uv_loop_t>) {
        uv_timer_init(loop, &timer.value)
        setHandlerData(on: &timer.value, to: &timer)
        uv_timer_start(&timer.value, handleScheduledJob(_:), timer.timeout, 0)
    }
}
