/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

import feathers.themes.steel.components.SteelActivityIndicatorStyles;
import feathers.themes.steel.components.SteelAlertStyles;
import feathers.themes.steel.components.SteelApplicationStyles;
import feathers.themes.steel.components.SteelAssetLoaderStyles;
import feathers.themes.steel.components.SteelButtonBarStyles;
import feathers.themes.steel.components.SteelButtonStyles;
import feathers.themes.steel.components.SteelCalloutStyles;
import feathers.themes.steel.components.SteelCheckStyles;
import feathers.themes.steel.components.SteelCollapsibleStyles;
import feathers.themes.steel.components.SteelComboBoxStyles;
import feathers.themes.steel.components.SteelDatePickerStyles;
import feathers.themes.steel.components.SteelDrawerStyles;
import feathers.themes.steel.components.SteelDrillDownItemRendererStyles;
import feathers.themes.steel.components.SteelFormItemStyles;
import feathers.themes.steel.components.SteelFormStyles;
import feathers.themes.steel.components.SteelGridViewStyles;
import feathers.themes.steel.components.SteelGroupListViewStyles;
import feathers.themes.steel.components.SteelHDividedBoxStyles;
import feathers.themes.steel.components.SteelHProgressBarStyles;
import feathers.themes.steel.components.SteelHScrollBarStyles;
import feathers.themes.steel.components.SteelHSliderStyles;
import feathers.themes.steel.components.SteelHeaderStyles;
import feathers.themes.steel.components.SteelHierarchicalItemRendererStyles;
import feathers.themes.steel.components.SteelItemRendererStyles;
import feathers.themes.steel.components.SteelLabelStyles;
import feathers.themes.steel.components.SteelLayoutGroupItemRendererStyles;
import feathers.themes.steel.components.SteelLayoutGroupStyles;
import feathers.themes.steel.components.SteelListViewStyles;
import feathers.themes.steel.components.SteelNumericStepperStyles;
import feathers.themes.steel.components.SteelPageIndicatorStyles;
import feathers.themes.steel.components.SteelPageNavigatorStyles;
import feathers.themes.steel.components.SteelPanelStyles;
import feathers.themes.steel.components.SteelPopUpDatePickerStyles;
import feathers.themes.steel.components.SteelPopUpListViewStyles;
import feathers.themes.steel.components.SteelRadioStyles;
import feathers.themes.steel.components.SteelRouterNavigatorStyles;
import feathers.themes.steel.components.SteelScrollContainerStyles;
import feathers.themes.steel.components.SteelStackNavigatorStyles;
import feathers.themes.steel.components.SteelTabBarStyles;
import feathers.themes.steel.components.SteelTabNavigatorStyles;
import feathers.themes.steel.components.SteelTextAreaStyles;
import feathers.themes.steel.components.SteelTextCalloutStyles;
import feathers.themes.steel.components.SteelTextInputStyles;
import feathers.themes.steel.components.SteelToggleButtonStyles;
import feathers.themes.steel.components.SteelToggleSwitchStyles;
import feathers.themes.steel.components.SteelToolTipStyles;
import feathers.themes.steel.components.SteelTreeGridViewStyles;
import feathers.themes.steel.components.SteelTreeViewStyles;
import feathers.themes.steel.components.SteelVDividedBoxStyles;
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

		SteelActivityIndicatorStyles.initialize(this);
		SteelAlertStyles.initialize(this);
		SteelApplicationStyles.initialize(this);
		SteelAssetLoaderStyles.initialize(this);
		SteelButtonStyles.initialize(this);
		SteelButtonBarStyles.initialize(this);
		SteelCalloutStyles.initialize(this);
		SteelCheckStyles.initialize(this);
		SteelCollapsibleStyles.initialize(this);
		SteelComboBoxStyles.initialize(this);
		SteelDatePickerStyles.initialize(this);
		SteelDrawerStyles.initialize(this);
		SteelDrillDownItemRendererStyles.initialize(this);
		SteelFormStyles.initialize(this);
		SteelFormItemStyles.initialize(this);
		SteelGridViewStyles.initialize(this);
		SteelGroupListViewStyles.initialize(this);
		SteelHDividedBoxStyles.initialize(this);
		SteelHeaderStyles.initialize(this);
		SteelHProgressBarStyles.initialize(this);
		SteelHScrollBarStyles.initialize(this);
		SteelHSliderStyles.initialize(this);
		SteelHierarchicalItemRendererStyles.initialize(this);
		SteelItemRendererStyles.initialize(this);
		SteelLabelStyles.initialize(this);
		SteelLayoutGroupStyles.initialize(this);
		SteelLayoutGroupItemRendererStyles.initialize(this);
		SteelListViewStyles.initialize(this);
		SteelNumericStepperStyles.initialize(this);
		SteelPageIndicatorStyles.initialize(this);
		SteelPageNavigatorStyles.initialize(this);
		SteelPanelStyles.initialize(this);
		SteelPopUpDatePickerStyles.initialize(this);
		SteelPopUpListViewStyles.initialize(this);
		SteelRadioStyles.initialize(this);
		SteelRouterNavigatorStyles.initialize(this);
		SteelScrollContainerStyles.initialize(this);
		SteelStackNavigatorStyles.initialize(this);
		SteelTabBarStyles.initialize(this);
		SteelTabNavigatorStyles.initialize(this);
		SteelTextAreaStyles.initialize(this);
		SteelTextCalloutStyles.initialize(this);
		SteelTextInputStyles.initialize(this);
		SteelToggleButtonStyles.initialize(this);
		SteelToggleSwitchStyles.initialize(this);
		SteelToolTipStyles.initialize(this);
		SteelTreeGridViewStyles.initialize(this);
		SteelTreeViewStyles.initialize(this);
		SteelVDividedBoxStyles.initialize(this);
		SteelVProgressBarStyles.initialize(this);
		SteelVScrollBarStyles.initialize(this);
		SteelVSliderStyles.initialize(this);
	}
}
