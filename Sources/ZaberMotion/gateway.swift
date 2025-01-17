import ZaberMotionCore
import NotificationCenter

typealias CallbackFn = @convention(c) (UnsafeMutableRawPointer?, Int64) -> Void

public func theLibraryFunction() {
        let gatewayCallback: CallbackFn = { (response: UnsafeMutableRawPointer?, tag: Int64) in
        print("Callback received - response: \(String(describing: response)), tag: \(tag)")
    }

    let eventCallback: CallbackFn = { (response: UnsafeMutableRawPointer?, _tag: Int64) in
        print("Event received - response: \(String(describing: response))")
        print("Notification Thread ID: \(Thread.current)")
        NotificationCenter.default.post(name: Notification.Name("ZaberMotionCoreEvent"), object: nil, userInfo: ["response": String(describing: response)])
    }

    let eventCallbackPtr: UnsafeMutableRawPointer = unsafeBitCast(eventCallback, to: UnsafeMutableRawPointer.self)
    ZaberMotionCore.zml_setEventHandler(42, eventCallbackPtr);

    // byte array copied from hello gateway test (see cpp/test/integration/test_main.cpp)
    let testRequestData: [UInt8] = [
        0x68, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00,
        0x02, 0x72, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x00, 0x0d, 0x00, 0x00,
        0x00, 0x74, 0x65, 0x73, 0x74, 0x2f, 0x72, 0x65, 0x71, 0x75, 0x65, 0x73,
        0x74, 0x00, 0x00, 0x3d, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x00, 0x00, 0x02,
        0x64, 0x61, 0x74, 0x61, 0x50, 0x69, 0x6e, 0x67, 0x00, 0x06, 0x00, 0x00,
        0x00, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x08, 0x72, 0x65, 0x74, 0x75,
        0x72, 0x6e, 0x45, 0x72, 0x72, 0x6f, 0x72, 0x00, 0x00, 0x08, 0x72, 0x65,
        0x74, 0x75, 0x72, 0x6e, 0x45, 0x72, 0x72, 0x6f, 0x72, 0x57, 0x69, 0x74,
        0x68, 0x44, 0x61, 0x74, 0x61, 0x00, 0x00, 0x00
    ]

    // byte array copied from gateway event test (see cpp/test/integration/test_main.cpp)
    let testRequestDataEvent: [UInt8] = [
        0x2a, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00,
        0x02, 0x72, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x00, 0x10, 0x00, 0x00,
        0x00, 0x74, 0x65, 0x73, 0x74, 0x2f, 0x65, 0x6d, 0x69, 0x74, 0x5f, 0x65,
        0x76, 0x65, 0x6e, 0x74, 0x00, 0x00
    ]

    print("Main Thread ID: \(Thread.current)")

    // gateway call test
    testRequestData.withUnsafeBytes({ bytes in
        let pointer: UnsafeRawPointer = bytes.baseAddress!
        let callbackPtr: UnsafeMutableRawPointer = unsafeBitCast(gatewayCallback, to: UnsafeMutableRawPointer.self)

        // GoInt32 zml_call(void* request, GoInt64 tag, void* callback, GoUint8 async);
        let result = ZaberMotionCore.zml_call(UnsafeMutableRawPointer(mutating: pointer), 13, callbackPtr, 0)
        print("Result: \(result)")
    })

    let semaphore = DispatchSemaphore(value: 0)

    NotificationCenter.default.addObserver(forName: Notification.Name("ZaberMotionCoreEvent"), object: nil, queue: nil) { notification in
        print("Notification received - userInfo: \(String(describing: notification.userInfo))")
        print("Observer Thread ID: \(Thread.current)")
        semaphore.signal()
    }

    // event test
    testRequestDataEvent.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> Void in
        let pointer: UnsafeRawPointer = bytes.baseAddress!
        let callbackPtr: UnsafeMutableRawPointer = unsafeBitCast(gatewayCallback, to: UnsafeMutableRawPointer.self)

        // GoInt32 zml_event(void* request, GoInt64 tag, void* callback, GoUint8 async);
        let result = ZaberMotionCore.zml_call(UnsafeMutableRawPointer(mutating: pointer), 17, callbackPtr, 0)
        print("Result: \(result)")
    })

    let result = semaphore.wait(timeout: .now() + .seconds(2))
    if result == .timedOut {
        print("Timeout waiting for notification")
    }

    // enum test
    enum CompassPoint: Int {
        case north = 0
        case south = 1
        case east = 2
        case west = 3
    }

    print("CompassPoint: \(CompassPoint.north)") // prints CompassPoint: north
    print("CompassPoint: \(CompassPoint.north.rawValue)") // prints CompassPoint: 0
}
