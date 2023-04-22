package funkin.backend.scripting;

class ModSubState extends MusicBeatSubstate {
	public static var lastName:String = null;
	public function new(stateName:String) {
		if (stateName != null)
			lastName = stateName;
		super(true, lastName);
	}
}