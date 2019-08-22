/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.macros;

#if macro
import haxe.macro.Expr.Function;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Context;

class StyleContextMacro {
	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var localClass = Context.getLocalClass().get();
		if (!localClass.meta.has(":styleContext")) {
			// nothing to add
			return fields;
		}
		var localClassName = localClass.name;
		var styleObject = "Class<feathers.style.IStyleObject>";
		var abc = null;
		var func:Function = {
			expr: macro return $i{localClassName},
			ret: (macro:Class<feathers.style.IStyleObject>),
			args: []
		};

		fields.push({
			name: "get_styleContext",
			access: [Access.APrivate, Access.AOverride],
			kind: FieldType.FFun(func),
			pos: Context.currentPos()
		});
		return fields;
	}
}
#end
