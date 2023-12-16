package funkin.backend.system.github;

#if GITHUB_API
import haxe.Json;
import haxe.Exception;
import haxe.Http;

// TODO: Document further and perhaps make this a Haxelib.
class GitHub {
	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user The user/group that owns the repository
	 * @param repository The repository name
	 * @return Releases
	 */
	public static function getReleases(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease> {
		try {
			var url = 'https://api.github.com/repos/${user}/${repository}/releases';

			var data = Json.parse(__requestOnGitHubServers(url));
			if (!(data is Array))
				throw __parseGitHubException(data);
			
			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		return [];
	}

	/**
	 * Gets the contributors list from a specific GitHub repository using the GitHub API.
	 * @param user The user/group that owns the repository
	 * @param repository The repository name
	 * @return Contributors List
	 */
	public static function getContributors(user:String, repository:String, ?onError:Exception->Void):Array<GitHubContributor> {
		try {
			var url = 'https://api.github.com/repos/${user}/${repository}/contributors';

			var data = Json.parse(__requestOnGitHubServers(url));
			if (!(data is Array))
				throw __parseGitHubException(data);
			
			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		return [];
	}

	/**
	 * Gets a specific GitHub user/group using the GitHub API.
	 * @param user The user/group to get
	 * @return User/Group
	 */
	public static function getUser(user:String, ?onError:Exception->Void):GitHubUser {
		try {
			var url = 'https://api.github.com/users/$user';

			var data = Json.parse(__requestOnGitHubServers(url));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);
			
			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		return null;
	}

	/**
	 * Filters all releases gotten by `getReleases`
	 * @param releases Releases
	 * @param keepPrereleases Whenever to keep Pre-Releases.
	 * @param keepDrafts Whenever to keep Drafts.
	 * @return Filtered releases.
	 */
	public static inline function filterReleases(releases:Array<GitHubRelease>, keepPrereleases:Bool = true, keepDrafts:Bool = false)
		return [for(release in releases) if (release != null && (!release.prerelease || (release.prerelease && keepPrereleases)) && (!release.draft || (release.draft && keepDrafts))) release];

	public static function __requestOnGitHubServers(url:String) {
		var h = new Http(url);
		h.setHeader("User-Agent", "request");

		var r = null;
		h.onStatus = function(s) {
			if(isRedirect(s))
				r = __requestOnGitHubServers(h.responseHeaders.get("Location"));
		};

		h.onData = function(d) {
			if(r == null) r = d;
		}
		h.onError = function(e) {
			throw e;
		}

		h.request(false);
		return r;
	}
	public static function __requestBytesOnGitHubServers(url:String) {
		var h = new Http(url);
		h.setHeader("User-Agent", "request");

		var r = null;
		h.onStatus = function(s) {
			if(isRedirect(s))
				r = __requestBytesOnGitHubServers(h.responseHeaders.get("Location"));
		};

		h.onBytes = function(d) {
			if(r == null) r = d;
		}
		h.onError = function(e) {
			throw e;
		}

		h.request(false);
		return r;
	}
	private static function isRedirect(status:Int):Bool {
        switch (status) {
			// 301: Moved Permanently, 302: Found (Moved Temporarily), 307: Temporary Redirect, 308: Permanent Redirect  - Nex_isDumb
            case 301 | 302 | 307 | 308 :
                trace("Redirected with status code: " + status);
				return true;
        }
		return false;
	}
	private static function __parseGitHubException(obj:Dynamic):GitHubException {
		var msg:String = "(No message)";
		var url:String = "(No API url)";
		if (Reflect.hasField(obj, "message"))
			msg = Reflect.field(obj, "message");
		if (Reflect.hasField(obj, "documentation_url"))
			url = Reflect.field(obj, "documentation_url");
		return new GitHubException(msg, url);
	}
}

#else
import haxe.Json;
import haxe.Exception;

class GitHub {
	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user 
	 * @param repository 
	 * @return Releases
	 */
	public static function getReleases(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease> {
		return [];
	}

	public static function getContributors(user:String, repository:String, ?onError:Exception->Void):Array<GitHubContributor> {
		return [];
	}

	/**
	 * Filters all releases gotten by `getReleases`
	 * @param releases Releases
	 * @param keepPrereleases Whenever to keep Pre-Releases.
	 * @param keepDrafts Whenever to keep Drafts.
	 * @return Filtered releases.
	 */
	public static inline function filterReleases(releases:Array<GitHubRelease>, keepPrereleases:Bool = true, keepDrafts:Bool = false)
		return releases;

	public static function __requestOnGitHubServers(url:String) {
		return null;
	}
	public static function __requestBytesOnGitHubServers(url:String) {
		return null;
	}
	private static function __parseGitHubException(obj:Dynamic):GitHubException {
		return null;
	}
}
#end