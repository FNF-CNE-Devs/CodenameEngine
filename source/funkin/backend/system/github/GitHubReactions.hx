package funkin.backend.system.github;

typedef GitHubReactions = {
	var url:String;
	var total_count:Int;
	// +1 and -1 cant be added, you need to use Reflect.field
	var laugh:Int;
	var hooray:Int;
	var confused:Int;
	var heart:Int;
	var rocket:Int;
	var eyes:Int;
}