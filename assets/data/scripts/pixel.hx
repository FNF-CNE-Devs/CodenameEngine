public var pixelNotesForBF = true;
public var pixelNotesForDad = true;
public var enablePixelUI = true;

var daPixelZoom = 6;

function onNoteCreation(event) {
    if (event.note.mustPress && !pixelNotesForBF) return;
    if (!event.note.mustPress && !pixelNotesForDad) return;
    
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
    if (event.player == 1 && !pixelNotesForBF) return;
    if (event.player == 0 && !pixelNotesForDad) return;

    event.cancel();

    var strum = event.strum;
    strum.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
    strum.animation.add("static", [event.strumID]);
    strum.animation.add("pressed", [4 + event.strumID, 8 + event.strumID], 12, false);
    strum.animation.add("confirm", [12 + event.strumID, 16 + event.strumID], 24, false);
    
    strum.scale.set(daPixelZoom, daPixelZoom);
    strum.updateHitbox();
}

function onCountdown(event) {
    if (!enablePixelUI) return;

    if (event.soundPath != null) event.soundPath = 'pixel/' + event.soundPath;
    event.antialiasing = false;
    event.scale = 6;
    event.spritePath = switch(event.swagCounter) {
        case 0: null;
        case 1: 'stages/school/ui/ready';
        case 2: 'stages/school/ui/set';
        case 3: 'stages/school/ui/go';
    };
}