//
function onDadHit(NoteHitEvent){
    if(health > 0.1 && Options.globalHealthDrain)
    {
        health = health - 0.018;
    }
}