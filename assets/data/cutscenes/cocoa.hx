function create() {
    startVideo(Paths.video("garfield"), function() {
        close();
    });
}