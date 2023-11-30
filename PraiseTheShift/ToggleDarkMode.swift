import Cocoa

/* TODO: Fix animation once the sun’s visual assets have been properly 
established.
For some reason, the transition is still not working as intended.
*/

func toggleDarkMode() {
    let defaults = UserDefaults.standard

    let transition: NSGlobalPreferenceTransition?
    if defaults.useTransition && PermissionUtil.checkScreenCapturePermission(canPrompt: true) {
        transition =
            NSGlobalPreferenceTransition.transition() as! NSGlobalPreferenceTransition?
    } else {
        transition = nil
    }

    setAppearanceTheme(to: !getAppearanceTheme(), notify: transition == nil)

    transition?.postChangeNotification(0) {}
}
