

package funkin.windows;

/**
 * Class for Windows-only functions, such as transparent windows, message boxes, and more.
 * Does not have any effect on other platforms.
 */
class WindowsAPI {
    @:dox(hide) public static function registerAudio() {
        #if windows
        native.WinAPI.registerAudio();
        #end
    }
    
    /**
     * Allocates a new console. The console will automatically be opened
     */
    public static function allocConsole() {
        #if windows
        native.WinAPI.allocConsole();
        #end
    }

    /**
     * Sets the window titlebar to dark mode (Windows 10 only)
     */
    public static function setDarkMode(enable:Bool) {
        #if windows
        native.WinAPI.setDarkMode(enable);
        #end
    }
}