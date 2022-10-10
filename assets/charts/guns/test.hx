import funkin.system.Conductor;
import flixel.tweens.FlxTween;
import funkin.scripting.events.NoteHitEvent;

function onPlayerHit(event:NoteHitEvent) {
    if (event.note.isSustainNote) return;
    event.preventDeletion();
    FlxTween.tween(event.note, {strumTime: event.note.strumTime + (Conductor.crochet * 2)}, Conductor.crochet / 500, {ease: FlxEase.cubeOut});
    event.note.wasGoodHit = false;
}