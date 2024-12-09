//
function postCreate() {
    speakers_sheet.frames = Paths.getFrames("stages/ezo/speakers_sheet");
    speakers_sheet.animation.addByPrefix("speakers_sheet", "speakers_sheet", 24, true);
    speakers_sheet.animation.play("speakers_sheet");
}