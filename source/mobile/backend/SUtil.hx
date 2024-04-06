package mobile.backend;

#if android
import android.Settings;
import android.content.Context;
#if debug
import android.widget.Toast;
#end
import android.os.Environment;
import android.Permissions;
import lime.app.Application;
#end
import funkin.backend.utils.NativeAPI;
import lime.system.System as LimeSystem;
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
	 #if sys
	 public static function getStorageDirectory(type:StorageType = #if OBB EXTERNAL_OBB #else EXTERNAL_DATA #end):String
	 {
		var daPath:String = '';

		#if android
		switch (type)
		{
			case EXTERNAL_DATA:
				daPath = Context.getExternalFilesDir(null);
			case EXTERNAL_OBB:
				daPath = Context.getObbDir();
		}
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
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

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'You forgor to add somethin\' in yo code :3'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');
			
			File.saveContent('saves/' + fileName + fileExtension, fileData);
			NativeAPI.showMessageBox("Success!", fileName + " file has been saved", MSG_INFORMATION);
		}
		catch (e:haxe.Exception)
			trace("File couldn't be saved.\n(${e.message})");
	}
	#end
}

enum StorageType
{
	EXTERNAL_DATA;
	EXTERNAL_OBB;
}