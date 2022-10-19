function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 168:
            camZoomingInterval = 1;
        case 200:
            camZoomingInterval = 4;
    }
}

function onPlayerHit(event:NoteHitEvent) {
    event.direction = 3 - event.direction;
}