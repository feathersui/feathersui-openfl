/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import haxe.macro.Type.EnumField;
import haxe.macro.Type.EnumType;
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
								if (abstractType.doc != null
									&& abstractType.doc.indexOf("@since ") == -1
									&& !StringTools.startsWith(StringTools.trim(abstractType.doc), "@see ")) {
									result.push({symbol: '${abstractType.name}', pos: abstractType.pos, tag: "since"});
								}
							}
						}
					case TEnum(t, params):
						var enumType = t.get();
						var enumPack = enumType.pack.join(".");
						if (packStart == null || (enumPack != null && StringTools.startsWith(enumType.pack.join("."), packStart))) {
							if (!enumType.isPrivate && !isHiddenByMetadata(enumType.meta)) {
								if (enumType.doc == null || enumType.doc.length == 0) {
									result.push({symbol: '${enumType.name}', pos: enumType.pos});
								}
								if (enumType.doc != null
									&& enumType.doc.indexOf("@since ") == -1
									&& !StringTools.startsWith(StringTools.trim(enumType.doc), "@see ")) {
									result.push({symbol: '${enumType.name}', pos: enumType.pos, tag: "since"});
								}
								for (name => construct in enumType.constructs) {
									checkEnumField(enumType, construct, result);
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
								if (classType.doc != null
									&& classType.doc.indexOf("@since ") == -1
									&& !StringTools.startsWith(StringTools.trim(classType.doc), "@see ")) {
									result.push({symbol: '${classType.name}', pos: classType.pos, tag: "since"});
								}
								if (classType.constructor != null) {
									checkField(classType, classType.constructor.get(), result);
								}
								var overrideNames = classType.overrides.map(field -> field.get().name);
								checkFields(classType, classType.fields.get().filter(field -> overrideNames.indexOf(field.name) == -1), result);
							}
						}
					case TType(t, params):
						var typedefType = t.get();
						var typedefPack = typedefType.pack.join(".");
						if (packStart == null || (typedefPack != null && StringTools.startsWith(typedefType.pack.join("."), packStart))) {
							if (!typedefType.isPrivate && !isHiddenByMetadata(typedefType.meta)) {
								if (typedefType.doc == null || typedefType.doc.length == 0) {
									result.push({symbol: '${typedefType.name}', pos: typedefType.pos});
								}
								if (typedefType.doc != null
									&& typedefType.doc.indexOf("@since ") == -1
									&& !StringTools.startsWith(StringTools.trim(typedefType.doc), "@see ")) {
									result.push({symbol: '${typedefType.name}', pos: typedefType.pos, tag: "since"});
								}
							}
						}
					default: // skip
				};
			}

			for (symbolAndPos in result) {
				if (symbolAndPos.tag != null) {
					Context.warning('Missing tag @${symbolAndPos.tag}: ${symbolAndPos.symbol}', symbolAndPos.pos);
				} else {
					Context.warning('Missing documentation: ${symbolAndPos.symbol}', symbolAndPos.pos);
				}
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
		} else if (field.doc.indexOf("@since ") == -1 && !StringTools.startsWith(StringTools.trim(field.doc), "@see ")) {
			result.push({symbol: '${classType.name}.${field.name}', pos: field.pos, tag: "since"});
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

	private static function checkEnumField(enumType:EnumType, field:EnumField, result:Array<SymbolAndPosition>):Void {
		if (field.doc == null || field.doc.length == 0) {
			if (isHiddenByMetadata(field.meta)) {
				return;
			}
			result.push({symbol: '${enumType.name}.${field.name}', pos: field.pos});
		} else if (field.doc.indexOf("@since ") == -1 && !StringTools.startsWith(StringTools.trim(field.doc), "@see ")) {
			result.push({symbol: '${enumType.name}.${field.name}', pos: field.pos, tag: "since"});
		}
	}
}

private typedef SymbolAndPosition = {
	symbol:String,
	pos:Position,
	?tag:String
}
#end
