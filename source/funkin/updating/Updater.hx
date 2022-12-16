package funkin.updating;

import sys.FileSystem;
import funkin.github.GitHubRelease;

class AsyncUpdater {
    // NON ASYNC STUFF
    #if REGION
    public function new(releases:Array<GitHubRelease>) {
        this.releases = releases;
    }
    
    public function execute() {
        Main.execAsync(installUpdates);
    }
    #end
    
    public var releases:Array<GitHubRelease>;
    public var progress:UpdaterProgress = new UpdaterProgress();
    public var path:String;
    
    public function installUpdates() {
        prepareInstallationEnvironment();

    }

    public function prepareInstallationEnvironment() {
        progress.step = PREPARING;
        
        #if windows
        path = '${Sys.getEnv("TEMP")}\\Codename Engine\\Updater\\';
        #else
        path = '.\\.temp\\';
        #end

        FileSystem.createDirectory(path);
    }
}

class UpdaterProgress {
    public var step:UpdaterStep = PREPARING;

    public function new() {}
}

@:enum
abstract UpdaterStep(Int) {
    var PREPARING = 0;
    var DOWNLOADING_ASSETS = 1;
    var DOWNLOADING_EXECUTABLE = 2;
    var INSTALLING = 3;
}