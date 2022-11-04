import funkin.system.Paths;

var daPixelZoom = 6;
// function onStrumCreation(event) {
//     event.cancel();

//     var strum = event.strum;
//     strum.loadGraphic(Paths.image('stages/school/arrows-pixels'), true, 17, 17);
//     strum.animation.add("scroll", [6 + strum.ID]);
// }

var song = PlayState.SONG.song.toLowerCase();
function onNoteCreation(event) {
    if (song == "test" && event.note.mustPress) return;
    event.cancel();

    var note = event.note;
    if (event.note.isSustainNote) {
        note.loadGraphic(Paths.image('stages/school/ui/arrowEnds'), true, 7, 6);
        note.animation.add("hold", [event.strumID]);
        note.animation.add("holdend", [4 + event.strumID]);
    } else {
        note.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
        note.animation.add("scroll", [4 + event.strumID]);
    }
    note.scale.set(daPixelZoom, daPixelZoom);
    note.updateHitbox();
}
function onStrumCreation(event) {
    if (song == "test" && event.player == 1) return;
    event.cancel();

    var strum = event.strum;
    strum.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
    strum.animation.add("static", [event.strumID]);
    strum.animation.add("pressed", [4 + event.strumID, 8 + event.strumID], 12, false);
    strum.animation.add("confirm", [12 + event.strumID, 16 + event.strumID], 24, false);
    
    strum.scale.set(daPixelZoom, daPixelZoom);
    strum.updateHitbox();
}