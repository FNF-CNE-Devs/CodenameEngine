package funkin.backend.scripting;

class ModState extends MusicBeatState {

	/**
	* Name of HScript file in assets/data/states.
	*/
	public static var lastName:String = null;
	
	/**
	* Optional extra data.
	*/
	public static var data:Dynamic = null;

	/**
	* ModState Constructor.
	* Inherits from MusicBeatState and allows the execution of an HScript from assets/data/states passed via parameters.
	* 
	* @param _stateName Name or path to a HScript file from assets/data/states.
	* @param _data Optional extra Dynamic data passed from a previous state (JSON suggested).
	*/
	public function new(_stateName:String, ?_data:Dynamic) {
		if(_stateName != null && _stateName != lastName) {
			lastName = _stateName;
		}

		if(_data != null)
			data = _data;

		super(true, lastName);
	}
}