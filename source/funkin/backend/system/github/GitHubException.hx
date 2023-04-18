package funkin.backend.system.github;

import haxe.Exception;

class GitHubException extends Exception {
	public var apiMessage:String;

	public var documentationUrl:String;

	public function new(apiMessage:String, documentationUrl:String) {
		super('[GitHubException] ${apiMessage} (Check ${documentationUrl})');
		this.apiMessage = apiMessage;
		this.documentationUrl = documentationUrl;
	}
}