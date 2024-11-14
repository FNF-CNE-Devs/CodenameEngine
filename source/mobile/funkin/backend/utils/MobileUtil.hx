/*
 * Copyright (C) 2024 Mobile Porting Team
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

package mobile.funkin.backend.utils;

#if android
import android.content.Context;
import android.os.Environment;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.Permissions;
import android.Settings;
#end
import lime.system.System as LimeSystem;
import funkin.backend.utils.NativeAPI;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * A storage class for mobile.
 * @author Lily Ross (mcagabe19)
 */
class MobileUtil
{
	#if sys
	public static function getStorageDirectory(?force:Bool = false):String
	{
		var daPath:String;

		#if android
		if (!FileSystem.exists(LimeSystem.applicationStorageDirectory + 'storagetype.txt'))
			File.saveContent(LimeSystem.applicationStorageDirectory + 'storagetype.txt', funkin.options.Options.storageType);
		var curStorageType:String = File.getContent(LimeSystem.applicationStorageDirectory + 'storagetype.txt');
		daPath = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#else
		daPath = Sys.getCwd();
		#end

		return daPath;
	}

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/$fileName', fileData);
			if (alert)
				NativeAPI.showMessageBox("Success!", '$fileName has been saved.', MSG_INFORMATION);
		}
		catch (e:haxe.Exception)
			if (alert)
				NativeAPI.showMessageBox("Error!", '$fileName couldn\'t be saved.\n(${e.message})', MSG_ERROR);
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}


	#if android
	public static function requestPermissionsFromUser():Void
	{
		if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU)
			Permissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!Environment.isExternalStorageManager())
		{
			if (VERSION.SDK_INT >= VERSION_CODES.S)
				Settings.requestSetting('REQUEST_MANAGE_MEDIA');
			Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((VERSION.SDK_INT >= VERSION_CODES.TIRAMISU && !Permissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES')) || (VERSION.SDK_INT < VERSION_CODES.TIRAMISU && !Permissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			NativeAPI.showMessageBox('Notice!', 'If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress Ok to see what happens', MSG_INFORMATION);

		try
		{
			if (!FileSystem.exists(MobileUtil.getStorageDirectory()))
				FileSystem.createDirectory(MobileUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			NativeAPI.showMessageBox('Error!', 'Please create folder to\n' + MobileUtil.getStorageDirectory(true) + '\nPress OK to close the game', MSG_ERROR);
			LimeSystem.exit(1);
		}
	}

	public static function checkExternalPaths(?splitStorage = false):Array<String> {
		var process = new funkin.backend.utils.native.HiddenProcess('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
		var paths:String = process.stdout.readAll().toString();
		if (splitStorage) paths = paths.replace('/storage/', '');
		return paths.split(',');
	}

	public static function getExternalDirectory(external:String):String {
		var daPath:String = '';
		for (path in checkExternalPaths())
			if (path.contains(external)) daPath = path;

		daPath = haxe.io.Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
		return daPath;
	}
	#end
	#end
}

#if android
enum abstract StorageType(String) from String to String
{
	final forcedPath = '/storage/emulated/0/';
	final packageNameLocal = 'com.yoshman29.codenameengine';
	final fileLocal = 'CodenameEngine';

	public static function fromStr(str:String):StorageType
	{
		final EXTERNAL_DATA = Context.getExternalFilesDir();
		final EXTERNAL_OBB = Context.getObbDir();
		final EXTERNAL_MEDIA = Environment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
		final EXTERNAL = Environment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: MobileUtil.getExternalDirectory(str) + '.' + fileLocal;
		}
	}

	public static function fromStrForce(str:String):StorageType
	{
		final EXTERNAL_DATA = forcedPath + 'Android/data/' + packageNameLocal + '/files';
		final EXTERNAL_OBB = forcedPath + 'Android/obb/' + packageNameLocal;
		final EXTERNAL_MEDIA = forcedPath + 'Android/media/' + packageNameLocal;
		final EXTERNAL = forcedPath + '.' + fileLocal;

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: MobileUtil.getExternalDirectory(str) + '.' + fileLocal;
		}
	}
}
#end
