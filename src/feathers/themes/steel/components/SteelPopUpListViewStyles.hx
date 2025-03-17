/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Button;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `PopUpListView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelPopUpListViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(PopUpListView, null) == null) {
			styleProvider.setStyleFunction(PopUpListView, null, function(listView:PopUpListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					listView.popUpAdapter = new DropDownPopUpAdapter();
				}
			});
		}
		if (styleProvider.getStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON, function(button:Button):Void {
				theme.styleProvider.getStyleFunction(Button, null)(button);

				button.horizontalAlign = LEFT;
				button.gap = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
				button.minGap = theme.mediumPadding;

				if (button.icon == null) {
					var icon = new TriangleSkin();
					icon.pointPosition = BOTTOM;
					icon.fill = SolidColor(theme.textColor);
					icon.disabledFill = SolidColor(theme.disabledTextColor);
					icon.width = 8.0;
					icon.height = 4.0;
					button.icon = icon;
				}

				button.iconPosition = RIGHT;
			});
		}
		if (styleProvider.getStyleFunction(ListView, PopUpListView.CHILD_VARIANT_LIST_VIEW) == null) {
			styleProvider.setStyleFunction(ListView, PopUpListView.CHILD_VARIANT_LIST_VIEW, function(listView:ListView):Void {
				theme.styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP)(listView);
			});
		}
	}
}
