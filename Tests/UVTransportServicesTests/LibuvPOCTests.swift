import Foundation
@testable import UVTransportServices
import XCTest

final class UVTransportServicesTests: XCTestCase {
    func testSample() throws {
        let group = UVEventLoopGroup(loopCount: 2)
        let loop = group.next()

        let lock = NSLock()
        var counter = 0

        let s = loop.scheduleTask(in: .seconds(1)) {
            lock.lock()
            defer { lock.unlock() }
            counter += 1
            print("Counter updated 3")
        }

        loop.execute {
            lock.lock()
            defer { lock.unlock() }
            counter += 1
            print("Counter updated")
        }

        loop.execute {
            lock.lock()
            defer { lock.unlock() }
            counter += 1
            print("Counter updated 2")
        }

        try s.futureResult.wait()

        loop.shutdownGracefully { _ in
            print("all loops are stopped")
        }

        XCTAssertEqual(counter, 3)
    }
}
