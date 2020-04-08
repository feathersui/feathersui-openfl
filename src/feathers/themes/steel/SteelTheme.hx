/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

import feathers.themes.steel.components.SteelApplicationStyles;
import feathers.themes.steel.components.SteelButtonStyles;
import feathers.themes.steel.components.SteelCalloutStyles;
import feathers.themes.steel.components.SteelCheckStyles;
import feathers.themes.steel.components.SteelComboBoxStyles;
import feathers.themes.steel.components.SteelGridViewStyles;
import feathers.themes.steel.components.SteelHProgressBarStyles;
import feathers.themes.steel.components.SteelHScrollBarStyles;
import feathers.themes.steel.components.SteelHSliderStyles;
import feathers.themes.steel.components.SteelItemRendererStyles;
import feathers.themes.steel.components.SteelLabelStyles;
import feathers.themes.steel.components.SteelLayoutGroupStyles;
import feathers.themes.steel.components.SteelListViewStyles;
import feathers.themes.steel.components.SteelPageIndicatorStyles;
import feathers.themes.steel.components.SteelPageNavigatorStyles;
import feathers.themes.steel.components.SteelPanelStyles;
import feathers.themes.steel.components.SteelPopUpListViewStyles;
import feathers.themes.steel.components.SteelRadioStyles;
import feathers.themes.steel.components.SteelScrollContainerStyles;
import feathers.themes.steel.components.SteelTabBarStyles;
import feathers.themes.steel.components.SteelTabNavigatorStyles;
import feathers.themes.steel.components.SteelTextAreaStyles;
import feathers.themes.steel.components.SteelTextCalloutStyles;
import feathers.themes.steel.components.SteelTextInputStyles;
import feathers.themes.steel.components.SteelToggleButtonStyles;
import feathers.themes.steel.components.SteelToggleSwitchStyles;
import feathers.themes.steel.components.SteelTreeViewStyles;
import feathers.themes.steel.components.SteelTreeViewItemRendererStyles;
import feathers.themes.steel.components.SteelVProgressBarStyles;
import feathers.themes.steel.components.SteelVScrollBarStyles;
import feathers.themes.steel.components.SteelVSliderStyles;

/**
	"Steel" theme. Unlike the default version, this version references all
	Feathers UI components, even if some are not used in the app.

	@since 1.0.0
**/
@:dox(hide)
class SteelTheme extends BaseSteelTheme {
	/**
		Creates a new `SteelTheme` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?themeColor:Int, ?darkThemeColor:Int) {
		super(themeColor, darkThemeColor);

		SteelApplicationStyles.initialize(this);
		SteelButtonStyles.initialize(this);
		SteelCalloutStyles.initialize(this);
		SteelCheckStyles.initialize(this);
		SteelComboBoxStyles.initialize(this);
		SteelGridViewStyles.initialize(this);
		SteelHProgressBarStyles.initialize(this);
		SteelHScrollBarStyles.initialize(this);
		SteelHSliderStyles.initialize(this);
		SteelItemRendererStyles.initialize(this);
		SteelLabelStyles.initialize(this);
		SteelLayoutGroupStyles.initialize(this);
		SteelListViewStyles.initialize(this);
		SteelPageIndicatorStyles.initialize(this);
		SteelPageNavigatorStyles.initialize(this);
		SteelPanelStyles.initialize(this);
		SteelPopUpListViewStyles.initialize(this);
		SteelRadioStyles.initialize(this);
		SteelScrollContainerStyles.initialize(this);
		SteelTabBarStyles.initialize(this);
		SteelTabNavigatorStyles.initialize(this);
		SteelTextAreaStyles.initialize(this);
		SteelTextCalloutStyles.initialize(this);
		SteelTextInputStyles.initialize(this);
		SteelToggleButtonStyles.initialize(this);
		SteelToggleSwitchStyles.initialize(this);
		SteelTreeViewStyles.initialize(this);
		SteelTreeViewItemRendererStyles.initialize(this);
		SteelVProgressBarStyles.initialize(this);
		SteelVScrollBarStyles.initialize(this);
		SteelVSliderStyles.initialize(this);
	}
}
