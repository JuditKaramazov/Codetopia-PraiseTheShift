import SwiftUI

extension View {
	func cursor(_ cursor: NSCursor) -> some View {
		return self.onHover { (inside) in
			if inside {
				cursor.push()
			} else {
				cursor.pop()
			}
		}
	}
}
