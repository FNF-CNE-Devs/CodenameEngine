package mobile.backend;

#if android
import android.content.Context;
import android.os.Environment;
import android.Permissions;
import android.Settings;
#end
import funkin.backend.utils.NativeAPI;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * A storage class for mobile.
 * @author Mihai Alexandru (M.A. Jigsaw) and Lily (mcagabe19)
 */
class SUtil
{
	#if sys
	public static function getStorageDirectory(?force:Bool = false #if (android), type:StorageType = #if EXTERNAL EXTERNAL #elseif OBB EXTERNAL_OBB #elseif MEDIA EXTERNAL_MEDIA #else EXTERNAL_DATA #end #end):String
	{
		var daPath:String = '';
		#if android
		var forcedPath:String = '/storage/emulated/0/';
		var packageNameLocal:String = 'com.yoshman29.codenameengine';
		var fileLocal:String = 'CodenameEngine';
		switch (type)
		{
			case EXTERNAL_DATA:
				daPath = force ? forcedPath + 'Android/data/' + packageNameLocal + '/files' : Context.getExternalFilesDir();
			case EXTERNAL_OBB:
				daPath = force ? forcedPath + 'Android/obb/' + packageNameLocal : Context.getObbDir();
			case EXTERNAL_MEDIA:
				daPath = force ? forcedPath + 'Android/media/' + packageNameLocal : Environment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
			case EXTERNAL:
				daPath = force ? forcedPath + '.' + fileLocal : Environment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
		}
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = lime.system.System.documentsDirectory;
		#end

		return daPath;
	}

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

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:haxe.Exception)
					trace('Error while creating folder. (${e.message}');
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgor to add somethin\' in yo code :3'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			NativeAPI.showMessageBox("Success!", fileName + " file has been saved", MSG_INFORMATION);
		}
		catch (e:haxe.Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	#if android
	public static function doPermissionsShit():Void
	{
		if (!Permissions.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(Permissions.WRITE_EXTERNAL_STORAGE))
		{
			Permissions.requestPermission(Permissions.READ_EXTERNAL_STORAGE);
			Permissions.requestPermission(Permissions.WRITE_EXTERNAL_STORAGE);
			NativeAPI.showMessageBox('Notice!', 'If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress Ok to see what happens', MSG_INFORMATION);
			if (!Environment.isExternalStorageManager())
				Settings.requestSetting("android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
		}
		else
		{
			try
			{
				if (!FileSystem.exists(SUtil.getStorageDirectory()))
					FileSystem.createDirectory(SUtil.getStorageDirectory());
			}
			catch (e:Dynamic)
			{
				NativeAPI.showMessageBox("Error!", "Please create folder to\n" + SUtil.getStorageDirectory(true) + "\nPress OK to close the game", MSG_ERROR);
				lime.system.System.exit(1);
			}
		}
	}
	#end
	#end
}

enum StorageType
{
	EXTERNAL_DATA;
	EXTERNAL_OBB;
	EXTERNAL_MEDIA;
	EXTERNAL;
}
