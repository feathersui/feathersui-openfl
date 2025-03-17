/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.ExprTools;
import haxe.macro.Type.ClassType;

class AddEventMeta {
	public static function find(?inPackage:String):Void {
		final packStart:String = inPackage == null ? null : inPackage;
		Context.onGenerate((types:Array<haxe.macro.Type>) -> {
			for (type in types) {
				switch (type) {
					case TInst(t, params):
						var classType = t.get();
						var classPack = classType.pack.join(".");
						if (packStart == null || (classPack != null && StringTools.startsWith(classType.pack.join("."), packStart))) {
							checkMeta(classType);
						}
					default: // skip
				};
			}
		});
	}

	private static function checkEventMeta(classType:ClassType, meta:MetadataEntry):Void {
		var params = meta.params;
		if (params.length != 1) {
			return;
		}
		var eventParamExpr = params[0];
		var eventParam = ExprTools.toString(eventParamExpr);
		var index = eventParam.lastIndexOf(".");
		if (index == -1) {
			return;
		}
		var className = eventParam.substr(0, index);
		if (StringTools.startsWith(className, "openfl.")) {
			className = "flash" + className.substr(6);
		}
		var eventName = eventParam.substr(index + 1).toLowerCase();
		index = eventName.indexOf("_", 0);
		while (index != -1) {
			eventName = eventName.substr(0, index) + eventName.charAt(index + 1).toUpperCase() + eventName.substr(index + 2);
			index = eventName.indexOf("_", index);
		}
		var eventMetaExpr = macro Event(name = $v{eventName}, type = $v{className});
		classType.meta.add(":meta", [eventMetaExpr], meta.pos);
	}

	private static function checkMeta(classType:ClassType):Void {
		var allMeta = classType.meta.get();
		for (meta in allMeta) {
			if (meta.name != ":event") {
				continue;
			}
			checkEventMeta(classType, meta);
		}
	}
}
#end
