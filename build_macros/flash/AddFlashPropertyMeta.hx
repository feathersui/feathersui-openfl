/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

#if macro
import haxe.macro.Context;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;

class AddFlashPropertyMeta {
	public static function find(?inPackage:String):Void {
		final packStart:String = inPackage == null ? null : inPackage;
		Context.onGenerate((types:Array<haxe.macro.Type>) -> {
			for (type in types) {
				switch (type) {
					case TInst(t, params):
						var classType = t.get();
						var classPack = classType.pack.join(".");
						if (packStart == null || (classPack != null && StringTools.startsWith(classType.pack.join("."), packStart))) {
							checkFields(classType, classType.fields.get());
						}
					default: // skip
				};
			}
		});
	}

	private static function checkField(classType:ClassType, field:ClassField):Void {
		switch (field.kind) {
			case FVar(read, write):
				if ((read.equals(AccCall) || write.match(AccCall)) && !field.meta.has(":flash.property")) {
					field.meta.add(":flash.property", [], field.pos);
				}
			default:
				return;
		}
	}

	private static function checkFields(classType:ClassType, fields:Array<ClassField>):Void {
		for (field in fields) {
			checkField(classType, field);
		}
	}
}
#end
