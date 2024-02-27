function postHide() {
	if(curTween != null) {
		if(animation.curAnim?.name == 'angry-show') curTween.cancel();
		else curTween.percent = 1;
	}
}