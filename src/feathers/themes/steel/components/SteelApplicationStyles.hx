/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import openfl.display.Stage;
import feathers.controls.Application;
import feathers.core.ScreenDensityScaleManager;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Application` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelApplicationStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Application, null) == null) {
			styleProvider.setStyleFunction(Application, null, function(app:Application):Void {
				if (app.scaleManager == null) {
					app.scaleManager = new ScreenDensityScaleManager();
				}
				#if feathersui_theme_manage_stage_color
				refreshStageColor(app.stage, theme);
				#end
			});
		}
	}

	private static function refreshStageColor(stage:Stage, theme:BaseSteelTheme):Void {
		if (stage == null) {
			return;
		}
		stage.color = theme.rootFillColor;
	}
}
