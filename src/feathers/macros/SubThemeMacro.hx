/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Adds a sub-theme for a specific UI component type, but only if that
	component is used somewhere in the project.

	@since 1.0.0
**/
class SubThemeMacro {
	public macro static function addSubTheme(requiredType:String, subThemeType:String):Expr {
		Context.onAfterTyping((types) -> {
			var found = false;
			for (type in types) {
				switch (type) {
					case TClassDecl(c):
						var got = c.get();
						if (got.module == requiredType) {
							found = true;
							break;
						}
					default:
				}
			}
			if (found) {
				var subThemeWrapperClassName = 'SubThemeWrapper_${subThemeType.split(".").join("_")}';
				var wrapper = macro class $subThemeWrapperClassName {
					public function new() {
						// reference the sub-theme class so that it will be included in
						// the final output
						$p{subThemeType.split(".")}
					}
				};
				Context.defineType(wrapper);
			}
		});
		return macro {
			if (Type.resolveClass($v{subThemeType}) != null) {
				Reflect.callMethod(Type.resolveClass($v{subThemeType}), Reflect.getProperty(Type.resolveClass($v{subThemeType}), "initialize"), [this]);
			}
		}
	}
}
