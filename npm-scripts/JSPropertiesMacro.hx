/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import sys.io.File;
import sys.FileSystem;

class JSPropertiesMacro {
	public macro static function defineProperties():Void {
		Context.onAfterTyping((types) -> {
			var foundTypes:Array<ClassType> = [];
			for (type in types) {
				switch (type) {
					case TClassDecl(cRef):
						var c = cRef.get();
						if(StringTools.startsWith(c.module, "feathers."))
						{
							foundTypes.push(c);
						}
					default:
						continue;
				}
			}

			var definePropertiesExpr = "const feathers = require(\"./feathers/index.js\");";
			for(type in foundTypes)
			{
				var foundFieldNames:Array<String> = [];
				for(field in type.fields.get())
				{
					if(field.meta.has(":flash.property"))
					{
						switch(field.kind)
						{
							case FVar(read, write):
								foundFieldNames.push(field.name);
							default:
								continue;
						}
					}
				}
				for(fieldName in foundFieldNames) {
					definePropertiesExpr += 'Object.defineProperty(${type.module}.prototype, "${fieldName}", { get: function() { return this.get_${fieldName}() }, set: function(value) { return this.set_${fieldName}(value); } });';
				}
			}
			definePropertiesExpr += "module.exports = feathers;";

			var filePath = Sys.getCwd() + "../lib/feathersui-defineProperties-wrapper.js";
			var output = File.write(filePath);
			output.writeString(definePropertiesExpr);
			output.close();
		});
	}
}
#end
