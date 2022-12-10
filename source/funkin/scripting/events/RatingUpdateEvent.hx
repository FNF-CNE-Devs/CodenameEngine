package funkin.scripting.events;

class RatingUpdateEvent extends CancellableEvent
{
	/**
		New combo
	**/
	public var rating:ComboRating;

	/**
		Old combo (may be null)
	**/
	public var oldRating:ComboRating;

	public function new(rating:ComboRating, oldRating:ComboRating)
	{
		super();
		this.rating = rating;
		this.oldRating = oldRating;
	}
}
