import Cocoa
import Combine
import KeyboardShortcuts
import ServiceManagement

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItemController = PraiseTheShiftStatusItemController()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		UserDefaults.standard.register(defaults: [
			UserDefaults.Keys.useTransition: true,
			UserDefaults.Keys.startAtLogin: false,
			UserDefaults.Keys.checkForUpdates: true,
		])

		// Registers global keyboard shortcut listener.
		KeyboardShortcuts.onKeyDown(for: .toggleDarkMode) {
			toggleDarkMode()
		}

		AppUpdateChecker.shared.startBackgroundChecking()

		UserDefaults.standard.addObserver(
			self,
			forKeyPath: UserDefaults.Keys.startAtLogin,
			options: [.initial, .new],
			context: nil
		)
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
		-> Bool
	{
		self.statusItemController.statusItem.isVisible = true

		return true
	}

	override func observeValue(
		forKeyPath keyPath: String?, of object: Any?,
		change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
	) {

		if object as? UserDefaults === UserDefaults.standard
			&& keyPath == UserDefaults.Keys.startAtLogin
		{

			if let new = change?[.newKey] as? Bool {
				SMLoginItemSetEnabled("net.JuditKaramazov.PraiseTheShiftLauncher" as CFString, new)
			}
		}
	}

	deinit {
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.startAtLogin)
	}
}
