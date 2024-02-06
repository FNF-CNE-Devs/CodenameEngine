package mobile.backend;

#if android
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;
import android.Permissions;
import lime.app.Application;
#end
import funkin.backend.utils.NativeAPI;
import haxe.io.Path;
import haxe.CallStack;
import lime.system.System as LimeSystem;
import openfl.utils.Assets as OpenflAssets;
import lime.utils.Log as LimeLogger;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * A class for mobile
 * @author Mihai Alexandru (M.A. Jigsaw)
 * @modification's author: Lily (mcagabe19)
 */
class SUtil
{
	/**
	 * This returns the external storage path that the game will use by the type.
	 */
	public static function getStorageDirectory():String
	{
		var daPath:String = '';

		#if android
		daPath = Context.getExternalFilesDir(null);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	#if sys
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code lol'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			NativeAPI.showMessageBox("Success!", fileName + " file has been saved", MSG_INFORMATION);
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			Toast.makeText("Error!\nClouldn't save the file because:\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nClouldn't save the file because:\n" + e);
			#end
		}
	}
	#end
}
