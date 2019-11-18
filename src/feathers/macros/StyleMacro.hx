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

class StyleMacro {
	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var extraFields:Array<Field> = [];
		fields = fields.map((field) -> {
			var hasStyleMeta = false;
			var meta = field.meta;
			if (meta != null) {
				for (entry in meta) {
					if (entry.name == ":style") {
						hasStyleMeta = true;
						break;
					}
				}
			}
			if (!hasStyleMeta) {
				return field;
			}
			switch (field.kind) {
				case FVar(type, e):
					if (e == null) {
						Context.error("Variable '"
							+ field.name
							+ "' is not initialized. Variables with @:style metadata must be initialized with a default value.",
							Context.currentPos());
					}

					// generate a setter
					var setter:Function = {
						expr: macro {
							if (!this.setStyle($v{field.name})) {
								return $i{field.name};
							}
							if (this._clearingStyles) {
								value = ${e};
							}
							if ($i{field.name} == value) {
								return $i{field.name};
							}
							$i{field.name} = value;
							this.setInvalid(feathers.core.InvalidationFlag.STYLES);
							return $i{field.name};
						},
						ret: type,
						args: [{name: "value", type: type}]
					};
					extraFields.push({
						name: "set_" + field.name,
						access: [Access.APrivate],
						kind: FieldType.FFun(setter),
						pos: Context.currentPos()
					});

					// change from a variable to a property
					var propField:Field = {
						name: field.name,
						access: field.access,
						kind: FieldType.FProp("default", "set", type, e),
						pos: field.pos,
						doc: field.doc,
						meta: field.meta
					};
					return propField;
				default:
					Context.error("@:style metadata not allowed on '" + field.name + "'. Field must be a variable, and no getter or setter may be defined.",
						Context.currentPos());
			}
		});
		if (extraFields.length > 0) {
			fields = fields.concat(extraFields);
		}
		return fields;
	}
}
#end
