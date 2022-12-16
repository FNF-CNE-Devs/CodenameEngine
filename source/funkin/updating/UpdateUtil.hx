package funkin.updating;

import funkin.github.GitHubRelease;
import funkin.github.GitHub;
import lime.app.Application;

using funkin.github.GitHub;

class UpdateUtil {
    public static function checkForUpdates():UpdateCheckCallback {
        var curTag = 'v${Application.current.meta.get('version')}';    
        trace(curTag);
        
        var error = false;

        // TODO: replace "CodenameTestRepo" by "CodenameEngine" once done.
        
        var newUpdates = __doReleaseFiltering(GitHub.getReleases("YoshiCrafter29", "CodenameTestRepo", function(e) {
            error = true;
        }), curTag);

        if (error) return {
            success: false,
            newUpdate: false
        };
        
        if (newUpdates.length <= 0) {
            return {
                success: true,
                newUpdate: false
            };
        }

        return {
            success: true,
            newUpdate: true,
            currentVersionTag: curTag,
            newVersionTag: newUpdates.last().tag_name,
            updates: newUpdates
        };
    }

    static var __curVersionPos = 0;
    static function __doReleaseFiltering(releases:Array<GitHubRelease>, currentVersionTag:String) {
        releases = releases.filterReleases(false, false);
        if (releases.length <= 0)
            return releases;

        var newArray:Array<GitHubRelease> = [];

        for(index in 0...releases.length) {
            var i = releases.length - 1 - index;

            var release = releases[i];
            if (release.tag_name == currentVersionTag) {
                __curVersionPos = index;
            }
            newArray.push(release);
        }

        return newArray.length <= 0 ? newArray : newArray.splice(__curVersionPos+1, newArray.length-(__curVersionPos+1));
    }

    /**
     * Replaces all `⚠ TEXT` into `<o>/!\ TEXT</o>`
     * @param text 
     */
    public static function parseWarnings(text:String) {
        text = parseEmote(text, "⚠", "<o>(!)", "<o>");
        text = parseEmote(text, "❌", "<r>(X)", "<r>");
        text = parseEmote(text, "✔", "<g>(+)", "<g>");
        text = parseEmote(text, "\n> ", "\n<gray>| ", "<gray>");
        return text;
    }

    public static function parseEmote(text:String, emote:String, beginning:String, end:String) {
        var index:Int;
        while((index = text.indexOf(emote)) >= 0) {
            var nextIndex = text.indexOf("\n", index + emote.length);
            if (nextIndex < 0)
                nextIndex = text.length;
            text = text.substr(0, index) + beginning + text.substring(index + emote.length, nextIndex) + end + text.substring(nextIndex);
        }
        return text;
    }
}

typedef UpdateCheckCallback = {
    var success:Bool;

    var newUpdate:Bool;

    @:optional var currentVersionTag:String;

    @:optional var newVersionTag:String;

    @:optional var updates:Array<GitHubRelease>;
}