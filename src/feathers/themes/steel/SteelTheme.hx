/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

import feathers.themes.steel.components.SteelTextInputStyles;
import feathers.themes.steel.components.SteelToggleButtonStyles;
import feathers.themes.steel.components.SteelToggleSwitchStyles;
import feathers.themes.steel.components.SteelVSliderStyles;
import feathers.themes.steel.components.SteelPanelStyles;
import feathers.themes.steel.components.SteelPopUpListStyles;
import feathers.themes.steel.components.SteelRadioStyles;
import feathers.themes.steel.components.SteelListViewStyles;
import feathers.themes.steel.components.SteelCheckStyles;
import feathers.themes.steel.components.SteelHProgressBarStyles;
import feathers.themes.steel.components.SteelVProgressBarStyles;
import feathers.themes.steel.components.SteelHSliderStyles;
import feathers.themes.steel.components.SteelLabelStyles;
import feathers.themes.steel.components.SteelItemRendererStyles;
import feathers.themes.steel.components.SteelLayoutGroupStyles;
import feathers.themes.steel.components.SteelButtonStyles;
import feathers.themes.steel.components.SteelApplicationStyles;
import feathers.themes.steel.components.SteelHScrollBarStyles;
import feathers.themes.steel.components.SteelVScrollBarStyles;
import feathers.themes.steel.components.SteelScrollContainerStyles;
import feathers.themes.steel.components.SteelCalloutStyles;
import feathers.themes.steel.components.SteelTextCalloutStyles;
import feathers.themes.steel.components.SteelComboBoxStyles;

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
		SteelHProgressBarStyles.initialize(this);
		SteelHScrollBarStyles.initialize(this);
		SteelHSliderStyles.initialize(this);
		SteelItemRendererStyles.initialize(this);
		SteelLabelStyles.initialize(this);
		SteelLayoutGroupStyles.initialize(this);
		SteelListViewStyles.initialize(this);
		SteelPanelStyles.initialize(this);
		SteelPopUpListStyles.initialize(this);
		SteelRadioStyles.initialize(this);
		SteelScrollContainerStyles.initialize(this);
		SteelTextCalloutStyles.initialize(this);
		SteelTextInputStyles.initialize(this);
		SteelToggleButtonStyles.initialize(this);
		SteelToggleSwitchStyles.initialize(this);
		SteelVProgressBarStyles.initialize(this);
		SteelVScrollBarStyles.initialize(this);
		SteelVSliderStyles.initialize(this);
	}
}
