function onNoteHit(e)
    if (e.noteType == "Hey!"){
        e.cancelAnim();
        for(char in e.characters) char.playAnim("hey");
    }