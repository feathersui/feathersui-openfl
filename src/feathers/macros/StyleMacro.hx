/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.macros;

#if macro
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Error;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Context;

/**
	Add `@:style` metadata to a public variable to convert it into a "style"
	property.

	```hx
	@:style
	public var backgroundSkin:DisplayObject = null;
	```

	The following requirements must be met when using `@:style` metadata:

	- The variable must be `public`
	- The variable must not have a getter or setter.
	- The variable must be initialized with a default value.
	- The variable's type must be nullable. For instance, use `Null<Float>` or `Null<Int>` for numeric types.

	@since 1.0.0
**/
class StyleMacro {
	@:dox(hide)
	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var extraFields:Array<Field> = [];
		fields = fields.map((field) -> {
			var styleMeta:MetadataEntry = null;
			var meta = field.meta;
			if (meta != null) {
				for (entry in meta) {
					if (entry.name == ":style") {
						styleMeta = entry;
						break;
					}
				}
			}
			if (styleMeta == null) {
				return field;
			}
			switch (field.kind) {
				case FVar(type, e):
					if (e == null) {
						throw new Error("Variable '"
							+ field.name
							+ "' is not initialized. Variables with @:style metadata must be initialized with a default value.",
							Context.currentPos());
					}

					var clearStyleName = "clearStyle_" + field.name;

					// generate a backing variable
					var backingVarName = "__" + field.name;
					extraFields.push({
						name: backingVarName,
						access: [Access.APrivate],
						kind: FieldType.FVar(type, e),
						pos: Context.currentPos(),
						meta: [
							{
								name: ":noCompletion",
								pos: Context.currentPos()
							}
						]
					});

					// generate a getter
					var getter:Function = {
						expr: macro {
							return $i{backingVarName};
						},
						ret: type,
						args: []
					};
					extraFields.push({
						name: "get_" + field.name,
						access: [Access.APrivate],
						kind: FieldType.FFun(getter),
						pos: Context.currentPos()
					});

					// generate a setter
					var setter:Function = {
						expr: macro {
							if (!this.setStyle($v{field.name})) {
								return $i{backingVarName};
							}
							if ($i{backingVarName} == value) {
								return $i{backingVarName};
							}
							// in a -final build, this forces the clearStyle
							// function to be kept if the property is kept
							// otherwise, it would be removed by dce/closure
							this._previousClearStyle = $i{clearStyleName};
							$i{backingVarName} = value;
							this.setInvalid(feathers.core.InvalidationFlag.STYLES);
							return $i{backingVarName};
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

					var clearFunction:Function = {
						expr: macro {
							$i{field.name} = ${e};
							return $i{field.name};
						},
						ret: type,
						args: []
					};
					extraFields.push({
						name: clearStyleName,
						access: [Access.APublic],
						kind: FieldType.FFun(clearFunction),
						pos: Context.currentPos(),
						meta: [
							{
								name: ":noCompletion",
								pos: Context.currentPos()
							},
							{
								name: ":dox",
								params: [
									{
										expr: EConst(CIdent("hide")),
										pos: Context.currentPos()
									}
								],
								pos: Context.currentPos()
							}
						]
					});

					// change from a variable to a property with get/set
					var propField:Field = {
						name: field.name,
						access: field.access,
						kind: FieldType.FProp("get", "set", type),
						pos: field.pos,
						doc: field.doc,
						meta: field.meta.concat([
							{
								name: ":flash.property",
								pos: Context.currentPos()
							}
						])
					};
					return propField;
				default:
					throw new Error("@:style metadata not allowed on '" + field.name + "'. Field must be a variable, and no getter or setter may be defined.",
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
