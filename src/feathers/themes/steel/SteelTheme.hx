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
import feathers.themes.steel.components.SteelListBoxStyles;
import feathers.themes.steel.components.SteelCheckStyles;
import feathers.themes.steel.components.SteelHProgressBarStyles;
import feathers.themes.steel.components.SteelHSliderStyles;
import feathers.themes.steel.components.SteelLabelStyles;
import feathers.themes.steel.components.SteelItemRendererStyles;
import feathers.themes.steel.components.SteelLayoutGroupStyles;
import feathers.themes.steel.components.SteelButtonStyles;
import feathers.themes.steel.components.SteelApplicationStyles;
import feathers.themes.steel.components.SteelHScrollBarStyles;
import feathers.themes.steel.components.SteelVScrollBarStyles;

/**
	@since 1.0.0
**/
class SteelTheme extends BaseSteelTheme {
	public function new(?themeColor:Int, ?darkThemeColor:Int) {
		super(themeColor, darkThemeColor);

		SteelApplicationStyles.initialize(this);
		SteelButtonStyles.initialize(this);
		SteelCheckStyles.initialize(this);
		SteelHProgressBarStyles.initialize(this);
		SteelHScrollBarStyles.initialize(this);
		SteelHSliderStyles.initialize(this);
		SteelItemRendererStyles.initialize(this);
		SteelLabelStyles.initialize(this);
		SteelLayoutGroupStyles.initialize(this);
		SteelListBoxStyles.initialize(this);
		SteelPanelStyles.initialize(this);
		SteelPopUpListStyles.initialize(this);
		SteelRadioStyles.initialize(this);
		SteelTextInputStyles.initialize(this);
		SteelToggleButtonStyles.initialize(this);
		SteelToggleSwitchStyles.initialize(this);
		SteelVScrollBarStyles.initialize(this);
		SteelVSliderStyles.initialize(this);
	}
}
