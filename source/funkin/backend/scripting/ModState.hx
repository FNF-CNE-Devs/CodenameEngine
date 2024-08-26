package funkin.backend.scripting;

class ModState extends MusicBeatState {
	public static var lastName:String = null;
	public static var data:Dynamic = null;

	public function new(_stateName:String, ?_data:Dynamic) {
		if(_stateName != null && _stateName != lastName) {
			lastName = _stateName;
			data = null;
		}

		if(_data != null)
			data = _data;

		super(true, lastName);
	}
}