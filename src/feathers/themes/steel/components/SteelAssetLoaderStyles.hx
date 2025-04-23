/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.AssetLoader;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `AssetLoader` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelAssetLoaderStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(AssetLoader, null) == null) {
			// sometimes, custom themes want to use default styles, so provide
			// an empty function so that something like this will work without
			// checking for null first.
			// styleProvider.getStyleFunction(ComponentType, null)(instance);
			styleProvider.setStyleFunction(AssetLoader, null, function(loader:AssetLoader):Void {});
		}
	}
}
