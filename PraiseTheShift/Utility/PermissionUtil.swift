import Cocoa

enum PermissionUtil {
	static func checkScreenCapturePermission(canPrompt: Bool) -> Bool {
		if canPrompt {
			let stream = CGDisplayStream(
				display: CGMainDisplayID(),
				outputWidth: 1,
				outputHeight: 1,
				pixelFormat: Int32(kCVPixelFormatType_32BGRA),
				properties: nil,
				handler: { _, _, _, _ in })

			return stream != nil
		} else {

			guard
				let windowList = CGWindowListCopyWindowInfo(
					.excludeDesktopElements, kCGNullWindowID)
					as NSArray?
			else { return false }

			for case let windowInfo as NSDictionary in windowList {
				let windowPID = windowInfo[kCGWindowOwnerPID] as? pid_t
				if windowPID == NSRunningApplication.current.processIdentifier {
					continue
				}

				guard windowInfo[kCGWindowOwnerName] as? String != "Window Server"
				else { continue }

				if windowInfo[kCGWindowName] != nil {
					return true
				}
			}
			return false
		}
	}
}
