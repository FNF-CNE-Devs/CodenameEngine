package mobile.backend;

#if android
import android.Settings;
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;
import android.Permissions;
import lime.app.Application;
import haxe.io.Path;
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
	 public static function getStorageDirectory(type:StorageType = #if EXTERNAL EXTERNAL #elseif OBB EXTERNAL_OBB #elseif MEDIA MEDIA #else EXTERNAL_DATA #end):String
	 {
		var daPath:String = '';

		#if android
		var path:String;
		switch (type)
		{
			case EXTERNAL_DATA:
				path = Context.getExternalFilesDir(null);
			case EXTERNAL_OBB:
				path = Context.getObbDir();
			case EXTERNAL:
				path = Environment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file');
			case MEDIA:
				path = Environment.getExternalStorageDirectory() + '/Android/media/' + Application.current.meta.get('packageName');
		}
		daPath = Path.addTrailingSlash(path);
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
			trace("Error!\nClouldn't save the file because:\n" + e);
			#end
		}
	}
	#end

	#if android
	public static function requestPermissions():Void
	{
		if (!Permissions.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(Permissions.WRITE_EXTERNAL_STORAGE))
		{
			Permissions.requestPermission(Permissions.READ_EXTERNAL_STORAGE);
			Permissions.requestPermission(Permissions.WRITE_EXTERNAL_STORAGE);
			NativeAPI.showMessageBox('Notice!', 'If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress Ok to see what happens', MSG_INFORMATION);
			if (!Environment.isExternalStorageManager())
				Settings.requestSetting("android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
		} else {
                try {
                if (!FileSystem.exists(SUtil.getStorageDirectory()))
                    FileSystem.createDirectory(SUtil.getStorageDirectory());
                }
                catch(e:Dynamic) {
				NativeAPI.showMessageBox("Error!", "Please create folder to\n" + #if EXTERNAL "/storage/emulated/0/." + Application.current.meta.get('file') #elseif MEDIA "/storage/emulated/0/Android/media/" + Application.current.meta.get('packageName') #else SUtil.getStorageDirectory() #end + "\nPress OK to close the game", MSG_ERROR);
                LimeSystem.exit(1);
                }}
	}
	#end
}

enum StorageType
{
	EXTERNAL;
	EXTERNAL_DATA;
	EXTERNAL_OBB;
	MEDIA;
}