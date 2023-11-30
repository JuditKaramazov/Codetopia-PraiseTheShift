import Foundation

final class ObservableUserDefault<T>: NSObject, ObservableObject {
	let defaults: UserDefaults
	let key: String

	var value: T {
		get {
			defaults.object(forKey: key) as! T
		}
		set {
			defaults.set(newValue, forKey: key)
		}
	}

	init(_ key: String, defaults: UserDefaults = UserDefaults.standard) {
		self.defaults = defaults
		self.key = key
		super.init()

		defaults.addObserver(self, forKeyPath: key, options: [], context: nil)
	}

	override func observeValue(
		forKeyPath keyPath: String?, of object: Any?,
		change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
	) {
		if object as? UserDefaults === defaults && keyPath == key {
			self.objectWillChange.send()
		}
	}

	deinit {
		// Removes the observer added in init.
		// Prevents a crash when this object is deallocated.
		defaults.removeObserver(self, forKeyPath: key)
	}
}
