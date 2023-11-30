import Foundation

final class AppUpdateChecker {
	static let shared = AppUpdateChecker()

	let localVersion: SemanticVersion? = {
		guard
			let bundleVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
				as? String
		else { return nil }
		return SemanticVersion(bundleVer)
	}()

	private(set) var remoteVersion: SemanticVersion?

	private(set) var isOutdated: Bool?

	private let updateScheduler: NSBackgroundActivityScheduler
	private static let schedulerIdentifier = "\(Bundle.main.bundleIdentifier!).updatecheck"
	private static let schedulerIntervalSecs = 60 * 60 * 6

	init() {
		updateScheduler = NSBackgroundActivityScheduler(
			identifier: AppUpdateChecker.schedulerIdentifier)
		updateScheduler.repeats = true
		updateScheduler.interval = TimeInterval(AppUpdateChecker.schedulerIntervalSecs)
	}

	/// Checks if there is an update available.
	/// Updates `remoteVersion` and `isOutdated`.
	func checkForUpdate() {
		guard UserDefaults.standard.checkForUpdates else { return }

		GithubAPI.getLatestRelease { (result) in
			switch result {
			case .success(let release):
				self.remoteVersion = SemanticVersion(release.version)

				if let remoteVersion = self.remoteVersion,
					let localVersion = self.localVersion
				{
					self.isOutdated = remoteVersion > localVersion

					#if DEBUG
						NSLog(
							"Update check successful, got remote version %@",
							remoteVersion.description)
					#endif

				} else {
					self.isOutdated = nil
				}

			case .failure(let error):
				NSLog(
					"Error checking for updates\n'%@'",
					error.localizedDescription)
			}
		}
	}

	/// Periodically checks for updates in the background.
	func startBackgroundChecking() {
		updateScheduler.schedule { completion in
			if self.updateScheduler.shouldDefer {
				completion(.deferred)
			} else {
				self.checkForUpdate()
				completion(.finished)
			}
		}
	}

	func stopBackgroundChecking() {
		updateScheduler.invalidate()
	}
}
