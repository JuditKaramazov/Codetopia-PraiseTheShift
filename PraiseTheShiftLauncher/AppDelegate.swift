import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		defer {
			NSApp.terminate(self)
		}
		
		let bundleID = "net.JuditKaramazov.PraiseTheShift"
		
		guard NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
			else { return }
		
		NSWorkspace.shared.launchApplication(
			withBundleIdentifier: bundleID,
			options: .withoutActivation,
			additionalEventParamDescriptor: nil,
			launchIdentifier: nil
		)
	}
}
