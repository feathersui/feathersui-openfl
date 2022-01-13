/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.MetaAccess;

class FindMissingDocs {
	public static function find(?inPackage:String):Void {
		final result:Array<SymbolAndPosition> = [];
		final packStart:String = inPackage == null ? null : inPackage;
		Context.onGenerate((types:Array<haxe.macro.Type>) -> {
			for (type in types) {
				switch (type) {
					case TAbstract(t, params):
						var abstractType = t.get();
						var abstractPack = abstractType.pack.join(".");
						if (packStart == null
							|| (abstractPack != null && StringTools.startsWith(abstractType.pack.join("."), packStart))) {
							if (!abstractType.isPrivate && !isHiddenByMetadata(abstractType.meta)) {
								if (abstractType.doc == null || abstractType.doc.length == 0) {
									result.push({symbol: '${abstractType.name}', pos: abstractType.pos});
								}
							}
						}
					case TInst(t, params):
						var classType = t.get();
						var classPack = classType.pack.join(".");
						if (packStart == null || (classPack != null && StringTools.startsWith(classType.pack.join("."), packStart))) {
							if (!classType.isPrivate && !isHiddenByMetadata(classType.meta)) {
								if (classType.doc == null || classType.doc.length == 0) {
									result.push({symbol: '${classType.name}', pos: classType.pos});
								}
								if (classType.constructor != null) {
									checkField(classType, classType.constructor.get(), result);
								}
								var overrideNames = classType.overrides.map(field -> field.get().name);
								checkFields(classType, classType.fields.get().filter(field -> overrideNames.indexOf(field.name) == -1), result);
							}
						}
					default: // skip
				};
			}

			for (symbolAndPos in result) {
				Context.warning('Missing documentation: ${symbolAndPos.symbol}', symbolAndPos.pos);
			}
		});
	}

	private static function isHiddenByMetadata(meta:MetaAccess):Bool {
		if (!meta.has(":dox")) {
			return false;
		}
		for (meta in meta.extract(":dox")) {
			for (param in meta.params) {
				switch (param.expr) {
					case EConst(CIdent(s)):
						if (s == "hide") {
							return true;
						}
					default:
				}
			}
		}
		return false;
	}

	private static function checkField(classType:ClassType, field:ClassField, result:Array<SymbolAndPosition>):Void {
		if (!field.isPublic) {
			return;
		}
		if (field.doc == null || field.doc.length == 0) {
			if (isHiddenByMetadata(field.meta)) {
				return;
			}
			result.push({symbol: '${classType.name}.${field.name}', pos: field.pos});
		}
	}

	private static function checkFields(classType:ClassType, fields:Array<ClassField>, result:Array<SymbolAndPosition>):Void {
		for (field in fields) {
			if (StringTools.startsWith(field.name, "get_")
				|| StringTools.startsWith(field.name, "set_")
				|| StringTools.startsWith(field.name, "clearStyle_")) {
				continue;
			}
			checkField(classType, field, result);
		}
	}
}

private typedef SymbolAndPosition = {
	symbol:String,
	pos:Position
}
#end
