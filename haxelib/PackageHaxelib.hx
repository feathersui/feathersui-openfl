/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
		var entries = new List<Entry>();
		addFile(FileSystem.absolutePath("../haxelib.json"), entries);
		addFile(FileSystem.absolutePath("../README.md"), entries);
		addFile(FileSystem.absolutePath("../CHANGELOG.md"), entries);
		addFile(FileSystem.absolutePath("../CONTRIBUTING.md"), entries);
		addFile(FileSystem.absolutePath("../LICENSE.md"), entries);
		addDirectory(FileSystem.absolutePath("../src"), true, entries);
		addDirectory(FileSystem.absolutePath("../tools"), true, entries);

		var jsonContent = File.getContent("../haxelib.json");
		var json = Json.parse(jsonContent);
		var packageName = Std.string(json.name);
		var packageVersion = Std.string(json.version);
		var releaseNote = Std.string(json.releasenote);
		var packageFileName = '${packageName}-${packageVersion}.zip';
		var zipFilePath = FileSystem.absolutePath(Path.join(["../build/", packageFileName]));
		Sys.println('haxelib: ${packageName}');
		Sys.println('version: ${packageVersion}');
		Sys.println('releasenote: ${releaseNote}');
		Sys.println('file: ${zipFilePath}');

		var zipFileOutput = File.write(zipFilePath, true);
		var zip = new Writer(zipFileOutput);
		zip.write(entries);
	}

	private static function addFile(filePath:String, result:List<Entry>):Void {
		addFileInternal(filePath, Path.directory(filePath), result);
	}

	private static function addDirectory(directoryPath:String, recursive:Bool, result:List<Entry>):Void {
		addDirectoryInternal(directoryPath, Path.directory(directoryPath), recursive, result);
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

	private static function addDirectoryInternal(directoryPath:String, relativeTo:String, recursive:Bool, result:List<Entry>):Void {
		for (fileName in FileSystem.readDirectory(directoryPath)) {
			var filePath = Path.join([directoryPath, fileName]);
			if (FileSystem.isDirectory(filePath)) {
				if (recursive) {
					addDirectoryInternal(filePath, relativeTo, true, result);
				}
			} else {
				addFileInternal(filePath, relativeTo, result);
			}
		}
	}
}
