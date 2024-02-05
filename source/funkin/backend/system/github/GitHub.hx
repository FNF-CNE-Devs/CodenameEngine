package funkin.backend.system.github;

#if GITHUB_API
import haxe.Json;
import haxe.Exception;
import haxe.Http;
#end

// TODO: Document further and perhaps make this a Haxelib.
class GitHub {
	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Releases
	 */
	public static function getReleases(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease> {
		#if GITHUB_API
		try {
			var data = Json.parse(__requestOnGitHubServers('https://api.github.com/repos/${user}/${repository}/releases'));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		#end
		return [];
	}

	/**
	 * Gets the contributors list from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Contributors List
	 */
	public static function getContributors(user:String, repository:String, ?onError:Exception->Void):Array<GitHubContributor> {
		#if GITHUB_API
		try {
			var data = Json.parse(__requestOnGitHubServers('https://api.github.com/repos/${user}/${repository}/contributors'));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		#end
		return [];
	}

	/**
	 * Gets a specific GitHub organization using the GitHub API.
	 * @param org The organization to get
	 * @param onError Error Callback
	 * @return Organization
	 */
	public static function getOrganization(org:String, ?onError:Exception->Void):GitHubOrganization {
		#if GITHUB_API
		try {
			var data = Json.parse(__requestOnGitHubServers('https://api.github.com/orgs/$org'));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		#end
		return null;
	}

	/**
	 * Gets the members list from a specific GitHub organization using the GitHub API.
	 * NOTE: Members use Contributors' structure!
	 * @param org The organization to get the members from
	 * @param onError Error Callback
	 * @return Members List
	 */
	 public static function getOrganizationMembers(org:String, ?onError:Exception->Void):Array<GitHubContributor> {
		#if GITHUB_API
		try {
			var data = Json.parse(__requestOnGitHubServers('https://api.github.com/orgs/$org/members'));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		#end
		return [];
	}

	/**
	 * Gets a specific GitHub user/organization using the GitHub API.
	 * NOTE: If organization, it will be returned with the structure of a normal user; use `getOrganization` if you specifically want an organization!
	 * @param user The user/organization to get
	 * @param onError Error Callback
	 * @return User/Organization
	 */
	 public static function getUser(user:String, ?onError:Exception->Void):GitHubUser {
		#if GITHUB_API
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
		#end
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
		return #if GITHUB_API [for(release in releases) if (release != null && (!release.prerelease || (release.prerelease && keepPrereleases)) && (!release.draft || (release.draft && keepDrafts))) release] #else releases #end;

	public static function __requestOnGitHubServers(url:String) {
		var r = null;
		#if GITHUB_API
		var h = new Http(url);
		h.setHeader("User-Agent", "request");

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
		#end
		return r;
	}
	public static function __requestBytesOnGitHubServers(url:String) {
		var r = null;
		#if GITHUB_API
		var h = new Http(url);
		h.setHeader("User-Agent", "request");

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
		#end
		return r;
	}
	private static function isRedirect(status:Int):Bool {
        switch (status) {
			// 301: Moved Permanently, 302: Found (Moved Temporarily), 307: Temporary Redirect, 308: Permanent Redirect  - Nex
            case 301 | 302 | 307 | 308 :
                trace("Redirected with status code: " + status);
				return true;
        }
		return false;
	}
	private static function __parseGitHubException(obj:Dynamic):GitHubException {
		#if GITHUB_API
		var msg:String = "(No message)";
		var url:String = "(No API url)";
		if (Reflect.hasField(obj, "message"))
			msg = Reflect.field(obj, "message");
		if (Reflect.hasField(obj, "documentation_url"))
			url = Reflect.field(obj, "documentation_url");
		return new GitHubException(msg, url);
		#else
		return null;
		#end
	}
}