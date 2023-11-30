func getAppearanceTheme() -> AppearanceTheme {
	return SLSGetAppearanceThemeLegacy() ? .dark : .light
}

/// Sets the appearance using SkyLight's private framework.
func setAppearanceTheme(to theme: AppearanceTheme, notify: Bool = false) {
	SLSSetAppearanceThemeNotifying(theme == .dark, notify)
}

enum AppearanceTheme {
	case light
	case dark
}

extension AppearanceTheme {
	static prefix func ! (appearanceTheme: AppearanceTheme) -> AppearanceTheme {
		return appearanceTheme == .light ? .dark : .light
	}
}
