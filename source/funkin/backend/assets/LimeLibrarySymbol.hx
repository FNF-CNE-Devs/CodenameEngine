package funkin.backend.assets;

/**
 * COPIED DIRECTLY FROM LIME SOURCE CAUSE LIME IS SO FUCKING DUMB!!
 */
class LimeLibrarySymbol
{
	public var library:lime.utils.AssetLibrary;
	public var libraryName:String;
	public var symbolName:String;

	public inline function new(id:String)
	{
		var colonIndex = id.indexOf(":");
		libraryName = id.substring(0, colonIndex);
		symbolName = id.substring(colonIndex + 1);
		library = lime.utils.Assets.getLibrary(libraryName);
	}

	public inline function isLocal(?type)
		return library.isLocal(symbolName, type);

	public inline function exists(?type)
		return library.exists(symbolName, type);
}