/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package tools;

import sys.io.File;
import haxe.Template;
import haxe.io.Path;
import sys.FileSystem;
import hxargs.Args;

class Run {
	public static function main() {
		// generate this path before calling Sys.setCwd()
		var templatePath = Path.join([Path.directory(Sys.programPath()), "templates"]);
		var args = Sys.args();
		var cwd = args.pop();
		Sys.setCwd(cwd);

		var getDoc:() -> String = null;
		var mainArgHandler = Args.generate([
			@doc("Creates a new Feathers UI project at the specified path")
			["new-project"] => function() {
				if (args.length == 0) {
					Sys.println("Error: Missing project path");
					var helpArgHandler = createHelpArgHandler();
					helpArgHandler.parse(["new-project"]);
					Sys.exit(1);
				}
				var projectPath = Path.normalize(FileSystem.absolutePath(args.shift()));
				var newProject = new NewProjectOptions(projectPath);
				var newProjectArgHandler = createNewProjectArgHandler(newProject);
				newProjectArgHandler.parse(args);
				createProject(newProject, Path.join([templatePath, "new-project"]));
			},
			@doc("Displays a list of available commands or the usage of a specific command")
			["help"] => function() {
				if (args.length > 0) {
					var helpArgHandler = createHelpArgHandler();
					helpArgHandler.parse(args);
				} else {
					Sys.println("Usage: haxelib run feathersui <command> [options]");
					Sys.println("Commands:");
					Sys.println(getDoc());
				}
			},
			_ => function(command:String) {
				Sys.println('Unknown command: ${command}');
				Sys.exit(1);
			}
		]);
		getDoc = mainArgHandler.getDoc;

		if (args.length == 0) {
			mainArgHandler.parse(["help"]);
			return;
		}
		mainArgHandler.parse(args.splice(0, 1));
	}

	private static function createHelpArgHandler() {
		return Args.generate([
			["new-project"] => function() {
				Sys.println("Usage: haxelib run feathersui new-project <path> [options]");
				Sys.println("Options:");
				Sys.println(createNewProjectArgHandler().getDoc());
			},
			["help"] => function() {
				Sys.println("Usage: haxelib run feathersui help <command>");
			},
			_ => function(command:String) {
				Sys.println('Unknown command: ${command}');
				Sys.exit(1);
			}
		]);
	}

	private static function validateNewProjectExists(newProject:NewProjectOptions):Void {
		if (newProject != null) {
			return;
		}
		Sys.println("Internal Error: NewProjectOptions missing");
		Sys.exit(1);
	}

	private static function createNewProjectArgHandler(?newProject:NewProjectOptions) {
		return Args.generate([
			@doc("The new project's main class will extend openfl.display.Sprite instead of feathers.controls.Application")
			["--openfl"] => function() {
				validateNewProjectExists(newProject);
				newProject.openfl = true;
			},
			@doc("The new project will include supporting files for Visual Studio Code")
			["--vscode"] => function() {
				validateNewProjectExists(newProject);
				newProject.vscode = true;
			},
			@doc("Show additional detailed output")
			["--verbose"] => function() {
				validateNewProjectExists(newProject);
				newProject.verbose = true;
			},
			_ => function(option:String) {
				Sys.println('Unknown option: ${option}');
				Sys.exit(1);
			}
		]);
	}

	private static function createProject(newProject:NewProjectOptions, templatePath:String):Void {
		var projectPath = newProject.path;
		var projectName = Path.withoutDirectory(projectPath);
		if (newProject.verbose) {
			Sys.println('New project: ${projectName}');
		}
		if (FileSystem.exists(projectPath)) {
			if (!FileSystem.isDirectory(projectPath)) {
				Sys.println('Failed to create project. File with project name already exists: ${projectPath}');
				Sys.exit(1);
			} else if (FileSystem.readDirectory(projectPath).length > 0) {
				Sys.println('Failed to create project. New project folder is not empty: ${projectPath}');
				Sys.exit(1);
			}
		}
		createFolder(projectPath, newProject.verbose);
		var srcPath = Path.join([projectPath, "src"]);
		createFolder(srcPath, newProject.verbose);

		var readmeTemplatePath = Path.join([templatePath, "README.md"]);
		var readmePath = Path.join([projectPath, "README.md"]);
		copyFile(readmeTemplatePath, readmePath, newProject.verbose);

		var projectXmlTemplatePath = Path.join([templatePath, "project.xml"]);
		var projectXmlPath = Path.join([projectPath, "project.xml"]);
		var projectTitle = projectName;
		var projectPackage = "com.example." + projectName;
		var projectCompany = "My Company";
		var projectXmlTemplateParams = {
			projectName: projectName,
			projectTitle: projectTitle,
			projectPackage: projectPackage,
			projectCompany: projectCompany,
			openfl: newProject.openfl
		};
		createFileFromTemplate(projectXmlTemplatePath, projectXmlPath, projectXmlTemplateParams, newProject.verbose);

		var mainTemplatePath = Path.join([templatePath, "Main.hx"]);
		var mainPath = Path.join([srcPath, projectName + ".hx"]);
		var baseClassName = newProject.openfl ? "Sprite" : "Application";
		var baseClassQualifiedName = newProject.openfl ? "openfl.display.Sprite" : "feathers.controls.Application";
		var mainTemplateParams = {
			projectName: projectName,
			baseClassName: baseClassName,
			baseClassQualifiedName: baseClassQualifiedName
		};
		createFileFromTemplate(mainTemplatePath, mainPath, mainTemplateParams, newProject.verbose);

		var assetsTemplatePath = Path.join([templatePath, "assets"]);
		var assetsPath = Path.join([projectPath, "assets"]);
		copyFolder(assetsTemplatePath, assetsPath, newProject.verbose);

		if (newProject.vscode) {
			var vscodeTemplatePath = Path.join([templatePath, ".vscode"]);
			var vscodePath = Path.join([projectPath, ".vscode"]);
			copyFolder(vscodeTemplatePath, vscodePath, newProject.verbose);
		}
	}

	private static function createFileFromTemplate(fromPath:String, toPath:String, templateParams:Dynamic, verbose:Bool):Void {
		var templateContent:String = null;
		try {
			templateContent = File.getContent(fromPath);
		} catch (e:Dynamic) {
			Sys.println('Failed to read template file: ${fromPath}');
			Sys.exit(1);
		}
		var template = new Template(templateContent);
		var templateResult = template.execute(templateParams);
		try {
			if (verbose) {
				Sys.println('Create file: ${toPath}');
			}
			File.saveContent(toPath, templateResult);
		} catch (e:Dynamic) {
			Sys.println('Failed to create file: ${toPath}');
			Sys.exit(1);
		}
	}

	private static function createFolder(folderPath:String, verbose:Bool):Void {
		try {
			if (verbose) {
				Sys.println('Create folder: ${folderPath}');
			}
			FileSystem.createDirectory(folderPath);
		} catch (e:Dynamic) {
			Sys.println('Failed to create folder: ${folderPath}');
			Sys.exit(1);
		}
	}

	private static function copyFile(fromPath:String, toPath:String, verbose:Bool):Void {
		try {
			if (verbose) {
				Sys.println('Create file: ${toPath}');
			}
			File.copy(fromPath, toPath);
		} catch (e:Dynamic) {
			Sys.println('Failed to create file: ${toPath}');
			Sys.exit(1);
		}
	}

	private static function copyFolder(fromPath:String, toPath:String, verbose:Bool):Void {
		createFolder(toPath, verbose);
		for (fileName in FileSystem.readDirectory(fromPath)) {
			var fileFrom = Path.join([fromPath, fileName]);
			var fileTo = Path.join([toPath, fileName]);
			if (FileSystem.isDirectory(fileFrom)) {
				copyFolder(fileFrom, fileTo, verbose);
			} else {
				copyFile(fileFrom, fileTo, verbose);
			}
		}
	}
}

class NewProjectOptions {
	public function new(path:String) {
		this.path = Path.removeTrailingSlashes(Path.normalize(path));
	}

	public var path:String;
	public var openfl:Bool;
	public var vscode:Bool;
	public var verbose:Bool;
}
