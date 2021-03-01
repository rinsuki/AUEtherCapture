import Foundation
import Pcap
//print(Pcap.Device.all())

func createCaptureSession() throws -> Pcap.CaptureSession? {
    for device in Pcap.Device.all() {
        let session = try Pcap.CaptureSession(device: device)
        if session.datalink != .ethernet {
            print("Skip \(device) because this device's datalink is not ethernet (\(session.datalink))")
            continue
        }
        return session
    }
    return nil
}

guard let session = try createCaptureSession() else {
    print("Failed to find network interface")
    exit(1)
}

print("session started", session)

while let (ts, packet) = session.next() {
    let ethernet = Ethernet(from: packet)
    print(ts.seconds, ethernet)
}

