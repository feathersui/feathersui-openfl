/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.ExprTools;
import haxe.macro.Type.ClassType;

class AddDefaultPropertyMeta {
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

	private static function checkDefaultPropertyMeta(classType:ClassType, meta:MetadataEntry):Void {
		var params = meta.params;
		if (params.length != 1) {
			return;
		}
		var propNameExpr = params[0];
		var defaultPropExpr = macro DefaultProperty($propNameExpr);
		classType.meta.add(":meta", [defaultPropExpr], meta.pos);
	}

	private static function checkMeta(classType:ClassType):Void {
		var allMeta = classType.meta.get();
		for (meta in allMeta) {
			if (meta.name != "defaultXmlProperty") {
				continue;
			}
			checkDefaultPropertyMeta(classType, meta);
		}
	}
}
#end
