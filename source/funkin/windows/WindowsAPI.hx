

package funkin.windows;

/**
 * Class for Windows-only functions, such as transparent windows, message boxes, and more.
 * Does not have any effect on other platforms.
 */
class WindowsAPI {
    public static function registerAudio() {
        #if windows
        native.WinAPI.registerAudio();
        #end
    }
}