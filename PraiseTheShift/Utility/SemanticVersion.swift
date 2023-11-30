import Foundation

struct SemanticVersion: Comparable, LosslessStringConvertible {
	let major: Int
	let minor: Int
	let patch: Int

	///
	/// - Parameters:
	///   - major: Major version, to be incremented when incompatible API changes are made.
	///   - minor: Minor version, to be incremented when backwards compatible functionality is added.
	///   - patch: Patch version, to be incremented when backwards compatible bug fixes are made.
	///
	init?(major: Int, minor: Int, patch: Int) {
		if major < 0 || minor < 0 || patch < 0 { return nil }

		self.major = major
		self.minor = minor
		self.patch = patch
	}

	///
	/// - Parameter string: A semantic version number in string format (*major.minor patch*).
	///
	init?(_ string: String) {
		let fullStringRange = NSRange(location: 0, length: string.utf16.count)
		guard
			let match = SemanticVersion.regex.firstMatch(
				in: string, options: [], range: fullStringRange)
		else { return nil }

		guard let majorRange = Range(match.range(at: 1), in: string),
			let minorRange = Range(match.range(at: 2), in: string),
			let patchRange = Range(match.range(at: 3), in: string)
		else { return nil }

		guard let major = Int(string[majorRange]),
			let minor = Int(string[minorRange]),
			let patch = Int(string[patchRange])
		else { return nil }

		if major < 0 || minor < 0 || patch < 0 { return nil }

		self.major = major
		self.minor = minor
		self.patch = patch
	}

	private static let regex: NSRegularExpression = {
		let pattern = #"^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$"#
		return try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
	}()

	static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
		if lhs.major != rhs.major {
			return lhs.major < rhs.major
		} else if lhs.minor != rhs.minor {
			return lhs.minor < rhs.minor
		} else {
			return lhs.patch < rhs.patch
		}
	}

	var description: String {
		return "\(major).\(minor).\(patch)"
	}
}
