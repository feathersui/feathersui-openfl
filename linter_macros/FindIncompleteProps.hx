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

class FindIncompleteProps {
	public static function find(?inPackage:String):Void {
		final result:Array<SymbolAndPosition> = [];
		final packStart:String = inPackage == null ? null : inPackage;
		Context.onGenerate((types:Array<haxe.macro.Type>) -> {
			for (type in types) {
				switch (type) {
					case TInst(t, params):
						var classType = t.get();
						var classPack = classType.pack.join(".");
						if (packStart == null || (classPack != null && StringTools.startsWith(classType.pack.join("."), packStart))) {
							if (!classType.isPrivate) {
								checkFields(classType, classType.fields.get(), result);
							}
						}
					default: // skip
				};
			}

			for (symbolAndPos in result) {
				Context.warning('Missing :flash.property ${symbolAndPos.symbol}', symbolAndPos.pos);
			}
		});
	}

	private static function checkField(classType:ClassType, field:ClassField, result:Array<SymbolAndPosition>):Void {
		if (!field.isPublic) {
			return;
		}
		switch (field.kind) {
			case FVar(read, write):
				if ((read.equals(AccCall) || write.match(AccCall)) && !field.meta.has(":flash.property")) {
					result.push({symbol: '${classType.name}.${field.name}', pos: field.pos});
				}
			default:
				return;
		}
	}

	private static function checkFields(classType:ClassType, fields:Array<ClassField>, result:Array<SymbolAndPosition>):Void {
		for (field in fields) {
			checkField(classType, field, result);
		}
	}
}

private typedef SymbolAndPosition = {
	symbol:String,
	pos:Position
}
#end
