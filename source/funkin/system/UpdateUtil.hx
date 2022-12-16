package funkin.system;

import funkin.github.GitHub;
import lime.app.Application;

class UpdateUtil {

    function checkForUpdates(callback:Bool->Void) {
        var curTag = 'v${Application.current.meta.get('version')}';    
        trace(curTag);
        
        var error = false;
        var releases = GitHub.getReleases("YoshiCrafter29", "YoshiCrafterEngine", function(e) {
            error = true;
            callback(false);
        });
        if (error) return;
    }
}

typedef UpdateCheckCallback = {
    var success:Bool;

    var newUpdate:Bool;

    var currentVersion:String;

    var newVersion:String;
}