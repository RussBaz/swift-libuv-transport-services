import Clibuv
import Dispatch
import Foundation

final class UVExecutionThread: Thread {
    private var loop: uv_loop_t
    private var jobs: UVJobs
    private var running = NSLock()

    override init() {
        loop = uv_loop_t()
        uv_loop_init(&loop)
        jobs = UVJobs(loop: &loop)
        jobs.set(timers: UVScheduledManager(loop: &loop))
        UVJobs.start(&jobs)
        super.init()
    }

    deinit {
        var counter = 0
        while true {
            counter += 1
            let result = uv_loop_close(&loop)

            if result == 0 { break }
            let name = uv_err_name(result).map { String(cString: $0) }
            let description = uv_strerror(result).map { String(cString: $0) }

            let message = if let name {
                if let description {
                    "[\(name): \(description)]"
                } else {
                    "[\(name)]"
                }
            } else {
                "[unknown code]"
            }

            print("Error: \(result) \(message)")

            guard counter < 15 else { fatalError("Could not deinit the uv_loop") }
        }
    }

    override func main() {
        running.lock()
        defer { running.unlock() }
        while true {
            guard !isCancelled else { break }
            print("starting the loop on thread: \(self)")
            uv_run(&loop, UV_RUN_DEFAULT)
            print("the loop on thread: \(self) stopped")
        }
    }

    override func cancel() {
        super.cancel()
        jobs.add(command: .stop)
    }

    func join() {
        running.lock()
        running.unlock()
    }

    func submitBlocking(_ task: @escaping UVTask) {
        jobs.add(command: .blocking(task: task))
    }

    func submitBlockingAfter(_ task: @escaping UVTask, timeout: UInt64) {
        jobs.add(command: .scheduleBlockingOnceAfter(task: task, timeout: timeout))
    }

    func submitBlockingAt(_ task: @escaping UVTask, timeout: UInt64) {
        jobs.add(command: .scheduleBlockingOnceAt(task: task, timeout: timeout))
    }
}
