package funkin.backend.scripting;

class ModState extends MusicBeatState {
	public static var lastName:String = null;
	public static var data:Dynamic = [];

	//New Constructor
	public function new(stateName:String, ?jsonData:Dynamic = null) {
		//State Name
		if (stateName != null)
			lastName = stateName;

		//Extra Data
		if(jsonData != null)
			data = jsonData;

		super(true, lastName);
	}
}