function onNoteHit(e){
    if (e.noteType == "GF Note"){
        e.cancelAnim();
        gf.playSingAnim(e.direction, e.animSuffix);
        // you can also do strumLines.members[2].characters[0].playSingAnim
        // very useful if you are making multiple people sing independently, requires multiple versions of this notetype though!
    }
}