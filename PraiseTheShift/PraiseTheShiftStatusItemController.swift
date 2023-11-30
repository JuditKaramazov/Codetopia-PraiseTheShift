import Cocoa
import Combine
import KeyboardShortcuts

/// Wrapper class around PraiseTheShift's `NSStatusItem` instance.
final class PraiseTheShiftStatusItemController {
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	private let contextMenu = NSMenu()

	private var subscription: Cancellable?

	var statusButton: NSStatusBarButton? {
		return statusItem.button
	}

	init() {
		statusItem.autosaveName = "PraiseTheShiftStatusItem"
		statusItem.behavior = .removalAllowed

		self.subscription = statusItem.publisher(for: \.isVisible)
			.removeDuplicates()
			.dropFirst()
			.sink { isVisible in
				if !isVisible {
					self.showHiddenIconDisclaimer()
				}
			}

		contextMenu.items = [
			NSMenuItem(
				title: "Toggle & Praise!",
				action: #selector(handleToggleDarkMode(_:)),
				target: self,
				shortcut: .toggleDarkMode
			),
			NSMenuItem.separator(),
			NSMenuItem(
				title: "Settings...",
				action: #selector(handleOpenPreferences(_:)),
				target: self,
				keyEquivalent: ","
			),
			NSMenuItem.separator(),
			NSMenuItem(
				title: "Update...",
				action: #selector(handleOpenUpdateWindow(_:)),
				target: self
			),
			NSMenuItem(
				title: "About PraiseTheShift",
				action: #selector(handleOpenAboutWindow(_:)),
				target: self
			),
			NSMenuItem(
				title: "Quit PraiseTheShift",
				action: #selector(NSApp.terminate(_:)),
				keyEquivalent: "q"
			),
		]

		// Configures the status item button.
		if let button = statusButton {
			button.image = NSImage(named: "MenubarIcon")
			button.toolTip = "Click to switch mode\nRight click for more options"
			button.target = self
			button.action = #selector(handleStatusButtonPress(_:))
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
	}

	func showContextMenu(_ sender: AnyObject? = nil) {
		statusItem.menu = contextMenu

		defer { statusItem.menu = nil }

		let showUpdate =
			UserDefaults.standard.checkForUpdates && (AppUpdateChecker.shared.isOutdated ?? false)
		contextMenu.item(withTitle: "Update...")?.isHidden = !showUpdate

		statusButton?.performClick(sender)
	}

	private func showHiddenIconDisclaimer() {
		let alert = NSAlert()
		alert.messageText = "PraiseTheShift has been hidden"
		alert.informativeText =
			"PraiseTheShift will continue to run in the background. To show it again, re-open the app."

		alert.runModal()
	}

	/// This handler function determines if the click was a left or right one
	/// (including control-click).
	@objc private func handleStatusButtonPress(_ sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }

		guard event.clickCount > 0 else { return }

		let controlKey = event.modifierFlags.contains(.control)

		if event.type == .rightMouseUp || (controlKey && event.type == .leftMouseUp) {
			showContextMenu(sender)
		} else if event.type == .leftMouseUp {
			toggleDarkMode()
		}
	}

	/// Handler function for "Toggle & Praise".
	@objc func handleToggleDarkMode(_ sender: NSMenuItem) {
		toggleDarkMode()
	}

	/// Handler function for "About PraiseTheShift".
	@objc func handleOpenAboutWindow(_ sender: NSMenuItem) {
		AboutWindowController.shared.showWindow(sender)
		NSApp.activate(ignoringOtherApps: true)
	}

	/// Handler function for the "Settings..." menu.
	@objc func handleOpenPreferences(_ sender: NSMenuItem) {
		guard let button = statusButton else { return }

		if !PreferencesPopover.shared.isShown {
			PreferencesPopover.shared.show(statusButton: button)
			NSApp.activate(ignoringOtherApps: true)
		}
	}

	/// Handler function for the "Update..." menu item.
	@objc func handleOpenUpdateWindow(_ sender: NSMenuItem) {
		let url = URL(string: "https://github.com/\(GithubAPI.repoFullName)/releases/latest")!
		NSWorkspace.shared.open(url)
	}
}
