package funkin.updating;

import funkin.options.Options;
import sys.FileSystem;
import haxe.io.Path;
import funkin.github.GitHubRelease;
import funkin.github.GitHub;
import lime.app.Application;

using funkin.github.GitHub;

class UpdateUtil {
    public static function init() {
        // deletes old bak file if it exists
        #if sys
        var bakPath = '${Path.withoutExtension(Sys.programPath())}.bak';
        if (FileSystem.exists(bakPath))
            FileSystem.deleteFile(bakPath);
        #end
    }

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
        releases = releases.filterReleases(Options.betaUpdates, false);
        if (releases.length <= 0)
            return releases;

        var newArray:Array<GitHubRelease> = [];

        for(index in 0...releases.length) {
            var i = releases.length - 1 - index;

            var release = releases[i];
            var containsBinary = false;
            for(asset in release.assets) {
                if (asset.name.toLowerCase() == AsyncUpdater.executableGitHubName.toLowerCase()) {
                    containsBinary = true;
                    break;
                }
            }
            if (containsBinary) {
                if (release.tag_name == currentVersionTag) {
                    __curVersionPos = index;
                }
                newArray.push(release);
            }
        }

        return newArray.length <= 0 ? newArray : newArray.splice(__curVersionPos+1, newArray.length-(__curVersionPos+1));
    }
}

typedef UpdateCheckCallback = {
    var success:Bool;

    var newUpdate:Bool;

    @:optional var currentVersionTag:String;

    @:optional var newVersionTag:String;

    @:optional var updates:Array<GitHubRelease>;
}