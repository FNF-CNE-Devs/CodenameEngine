function beatHit(curBeat) {
    switch(curBeat) {
        case 16:
            gf.danceSpeed = 2;
        case 48:
            gf.danceSpeed = 0;
        case 80:
            gf.danceSpeed = 2;
        case 112:
            gf.danceSpeed = 0;
    }
}