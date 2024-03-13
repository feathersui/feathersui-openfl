/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import haxe.Json;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Writer;
import sys.FileSystem;
import sys.io.File;

class PackageHaxelib {
	public static function main():Void {
		final destDir = FileSystem.absolutePath("../bin/haxelib");
		if (FileSystem.exists(destDir)) {
			deleteDir(destDir);
		}
		FileSystem.createDirectory(destDir);

		copyFile(FileSystem.absolutePath("../haxelib.json"), destDir);
		copyFile(FileSystem.absolutePath("../include.xml"), destDir);
		copyFile(FileSystem.absolutePath("../README.md"), destDir);
		copyFile(FileSystem.absolutePath("../CHANGELOG.md"), destDir);
		copyFile(FileSystem.absolutePath("../CONTRIBUTING.md"), destDir);
		copyFile(FileSystem.absolutePath("../LICENSE.md"), destDir);
		copyDir(FileSystem.absolutePath("../src"), destDir);
		copyDir(FileSystem.absolutePath("../tools"), destDir);

		var entries = new List<Entry>();
		addDirectory(destDir, entries);

		var jsonContent = File.getContent("../haxelib.json");
		var json = Json.parse(jsonContent);
		var packageName = Std.string(json.name);
		var packageVersion = Std.string(json.version);
		var releaseNote = Std.string(json.releasenote);
		var packageFileName = '${packageName}-${packageVersion}-haxelib.zip';
		var outputFolderPath = FileSystem.absolutePath("../bin/");
		FileSystem.createDirectory(outputFolderPath);
		var zipFilePath = Path.join([outputFolderPath, packageFileName]);
		Sys.println('haxelib: ${packageName}');
		Sys.println('version: ${packageVersion}');
		Sys.println('releasenote: ${releaseNote}');
		Sys.println('file: ${zipFilePath}');

		var zipFileOutput = File.write(zipFilePath, true);
		var zip = new Writer(zipFileOutput);
		zip.write(entries);
	}

	private static function copyFile(filePath:String, destDir:String):Void {
		var fileName = Path.withoutDirectory(filePath);
		File.copy(filePath, Path.join([destDir, fileName]));
	}

	private static function copyDir(directoryPath:String, destParentDir:String):Void {
		var dirName = Path.withoutDirectory(directoryPath);
		var destDirPath = Path.join([destParentDir, dirName]);
		FileSystem.createDirectory(destDirPath);
		for (fileName in FileSystem.readDirectory(directoryPath)) {
			var filePath = Path.join([directoryPath, fileName]);
			if (FileSystem.isDirectory(filePath)) {
				copyDir(filePath, destDirPath);
			} else {
				// extra files on macOS that should be skipped
				if (fileName == ".DS_Store") {
					continue;
				}
				copyFile(filePath, destDirPath);
			}
		}
	}

	private static function deleteDir(directoryPath:String):Void {
		for (fileName in FileSystem.readDirectory(directoryPath)) {
			var filePath = Path.join([directoryPath, fileName]);
			if (FileSystem.isDirectory(filePath)) {
				deleteDir(filePath);
			} else {
				FileSystem.deleteFile(filePath);
			}
		}
		FileSystem.deleteDirectory(directoryPath);
	}

	private static function addFile(filePath:String, result:List<Entry>):Void {
		addFileInternal(filePath, Path.directory(filePath), result);
	}

	private static function addDirectory(directoryPath:String, result:List<Entry>):Void {
		addDirectoryInternal(directoryPath, directoryPath, result);
	}

	private static function addFileInternal(filePath:String, relativeToDirPath:String, result:List<Entry>):Void {
		var fileName = StringTools.replace(filePath, relativeToDirPath + "/", "");
		var bytes = Bytes.ofData(File.getBytes(filePath).getData());
		result.add({
			fileName: fileName,
			fileSize: bytes.length,
			fileTime: Date.now(),
			compressed: false,
			dataSize: 0,
			data: bytes,
			crc32: Crc32.make(bytes)
		});
	}

	private static function addDirectoryInternal(directoryPath:String, relativeTo:String, result:List<Entry>):Void {
		for (fileName in FileSystem.readDirectory(directoryPath)) {
			var filePath = Path.join([directoryPath, fileName]);
			if (FileSystem.isDirectory(filePath)) {
				addDirectoryInternal(filePath, relativeTo, result);
			} else {
				addFileInternal(filePath, relativeTo, result);
			}
		}
	}
}
