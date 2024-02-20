/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Form;
import feathers.layout.FormLayout;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Form` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelFormStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Form, null) == null) {
			styleProvider.setStyleFunction(Form, null, function(form:Form):Void {
				if (form.layout == null) {
					var layout = new FormLayout();
					layout.gap = theme.mediumPadding;
					form.layout = layout;
				}
			});
		}
	}
}
