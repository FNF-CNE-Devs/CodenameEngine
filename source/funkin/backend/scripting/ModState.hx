package funkin.backend.scripting;

class ModState extends MusicBeatState {
	public static var lastName:String = null;
	public function new(stateName:String) {
		if (stateName != null)
			lastName = stateName;
		super(true, lastName);
	}
}