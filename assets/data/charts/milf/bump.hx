import funkin.ui.Alphabet;

function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 168:
            camZoomingInterval = 1;
        case 200:
            camZoomingInterval = 4;
    }
}

function createPost() {
    trace("OH FUCK");
    var alpha = new Alphabet(0, 0, "azertyuiopmlkjhgfdsqwxcvbnAZERTYUIOPMLKJHGFDSQWXCVBN");
    add(alpha);
}