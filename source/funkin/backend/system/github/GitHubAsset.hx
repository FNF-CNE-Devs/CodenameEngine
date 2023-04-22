package funkin.backend.system.github;

import funkin.backend.system.github.GitHubUser;

typedef GitHubAsset = {
	var url:String;
	var id:Int;
	var node_id:String;
	var name:String;
	var label:String;
	var uploader:GitHubUser;
	var content_type:String;
	var state:String;
	var size:UInt;
	var download_count:Int;
	var created_at:String;
	var updated_at:String;
	var browser_download_url:String;
}