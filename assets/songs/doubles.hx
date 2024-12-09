// CoolSwaged By MrSropical
// Orignal Script by YSB573
public var disableGhosts:Bool = false;

var data:Map<Int, {colors:Array<FlxColor>, lastNote:{time:Float, id:Int}}> = [];


function postCreate() {
	for (sl in strumLines.members)
		data[strumLines.members.indexOf(sl)] = {
			colors: [for (character in sl.characters) character.iconColor != null ? character.iconColor : switch(sl.data.position) {
				default: 0xFFFF0000;
				case 'boyfriend': 0xFF00FFFF;
			}],

			lastNote: {
				time: -9999,
				id: -1
			}
		};
}

function onNoteHit(event:NoteHitEvent) {
	if (event.note.isSustainNote) return;

	var target = data[strumLines.members.indexOf(event.note.strumLine)];
	var doDouble = (event.note.strumTime - target.lastNote.time) <= 2 && event.note.noteData != target.lastNote.id;
	target.lastNote.time = event.note.strumTime;
	target.lastNote.id = event.note.noteData;

	if(doDouble && !disableGhosts)
		for (character in event.characters)
			if (character.visible) doGhostAnim(character, target.colors[event.characters.indexOf(character)]).playAnim(character.getAnimName(), true);
}

function doGhostAnim(char:Character, color:FlxColor) {
	camGame.zoom += .015;
	camHUD.zoom += .007;

	var trail:Character = new Character(char.x, char.y, char.curCharacter, char.isPlayer);
	trail.color = color;
	insert(members.indexOf(char), trail);
	FlxTween.tween(trail, {alpha: 0}, .55).onComplete = function() {
		trail.kill();
		remove(trail, true);
	};
	if (strumLines.members[curCameraTarget].characters[0].getAnimName() == "singUP" || strumLines.members[curCameraTarget].characters[0].getAnimName() == "singUP-alt") {
    FlxTween.tween(trail, {y: char.y - 100}, .85, {ease: FlxEase.cubeOut});
    }
	if (strumLines.members[curCameraTarget].characters[0].getAnimName() == "singDOWN" || strumLines.members[curCameraTarget].characters[0].getAnimName() == "singDOWN-alt") {
        FlxTween.tween(trail, {y: char.y + 100}, .85, {ease: FlxEase.cubeOut});
    }
	if (strumLines.members[curCameraTarget].characters[0].getAnimName() == "singLEFT" || strumLines.members[curCameraTarget].characters[0].getAnimName() == "singLEFT-alt") {
        FlxTween.tween(trail, {x: char.x - 100}, .85, {ease: FlxEase.cubeOut});
    }
	if (strumLines.members[curCameraTarget].characters[0].getAnimName() == "singRIGHT" || strumLines.members[curCameraTarget].characters[0].getAnimName() == "singRIGHT-alt") {
        FlxTween.tween(trail, {x: char.x + 100}, .85, {ease: FlxEase.cubeOut});
    }
	return trail;
}