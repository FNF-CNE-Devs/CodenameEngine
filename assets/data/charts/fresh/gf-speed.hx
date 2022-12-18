function beatHit(curBeat) {
    switch(curBeat) {
        case 16:
            gf.danceSpeed = 2;
        case 48:
            gf.danceSpeed = 1;
        case 80:
            gf.danceSpeed = 2;
        case 112:
            gf.danceSpeed = 1;
    }
}