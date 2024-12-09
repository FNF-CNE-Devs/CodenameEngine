function postCreate()
{
    healthBar.numDivisions = 10000;
}

var lerpHealth:Float = 1;
var startLerpHealth:Bool = false; // made to prevent a visual issue when loading up a song

function postUpdate()
{
    lerpHealth = CoolUtil.fpsLerp(lerpHealth, (health * 50), 0.15);

    if (startLerpHealth)
        healthBar.percent = lerpHealth;
}

function onSongStart()
{
    startLerpHealth = true;
}