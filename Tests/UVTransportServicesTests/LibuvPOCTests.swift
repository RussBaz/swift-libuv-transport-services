import NIOConcurrencyHelpers
@testable import UVTransportServices
import XCTest

final class UVTransportServicesTests: XCTestCase {
    func testSample() throws {
        let group = UVEventLoopGroup(loopCount: 2)
        let loop = group.next()

        let counter = NIOLockedValueBox(0)

        let s = loop.scheduleTask(in: .seconds(1)) {
            counter.withLockedValue {
                $0 += 1
            }
            print("Counter updated 3")
        }

        loop.execute {
            counter.withLockedValue {
                $0 += 1
            }
            print("Counter updated")
        }

        loop.execute {
            counter.withLockedValue {
                $0 += 1
            }
            print("Counter updated 2")
        }

        try s.futureResult.wait()

        loop.shutdownGracefully { _ in
            print("all loops are stopped")
        }

        XCTAssertEqual(counter.withLockedValue { $0 }, 3)
    }
}
