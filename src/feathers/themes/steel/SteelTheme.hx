/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

import feathers.macros.SubThemeMacro;

/**
	The default "Steel" theme.

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

		SubThemeMacro.addSubTheme("feathers.core.Application", "feathers.themes.steel.components.SteelApplicationStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Button", "feathers.themes.steel.components.SteelButtonStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Callout", "feathers.themes.steel.components.SteelCalloutStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Check", "feathers.themes.steel.components.SteelCheckStyles");
		SubThemeMacro.addSubTheme("feathers.controls.ComboBox", "feathers.themes.steel.components.SteelComboBoxStyles");
		SubThemeMacro.addSubTheme("feathers.controls.GridView", "feathers.themes.steel.components.SteelGridViewStyles");
		SubThemeMacro.addSubTheme("feathers.controls.HProgress", "feathers.themes.steel.components.SteelHProgressBarStyles");
		SubThemeMacro.addSubTheme("feathers.controls.HScrollBar", "feathers.themes.steel.components.SteelHScrollBarStyles");
		SubThemeMacro.addSubTheme("feathers.controls.HSlider", "feathers.themes.steel.components.SteelHSliderStyles");
		SubThemeMacro.addSubTheme("feathers.controls.dataRenderers.ItemRenderer", "feathers.themes.steel.components.SteelItemRendererStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Label", "feathers.themes.steel.components.SteelLabelStyles");
		SubThemeMacro.addSubTheme("feathers.controls.LayoutGroup", "feathers.themes.steel.components.SteelLayoutGroupStyles");
		SubThemeMacro.addSubTheme("feathers.controls.ListView", "feathers.themes.steel.components.SteelListViewStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Panel", "feathers.themes.steel.components.SteelPanelStyles");
		SubThemeMacro.addSubTheme("feathers.controls.PopUpListView", "feathers.themes.steel.components.SteelPopUpListViewStyles");
		SubThemeMacro.addSubTheme("feathers.controls.Radio", "feathers.themes.steel.components.SteelRadioStyles");
		SubThemeMacro.addSubTheme("feathers.controls.ScrollContainer", "feathers.themes.steel.components.SteelScrollContainerStyles");
		SubThemeMacro.addSubTheme("feathers.controls.TabBar", "feathers.themes.steel.components.SteelTabBarStyles");
		SubThemeMacro.addSubTheme("feathers.controls.TextArea", "feathers.themes.steel.components.SteelTextAreaStyles");
		SubThemeMacro.addSubTheme("feathers.controls.TextCallout", "feathers.themes.steel.components.SteelTextCalloutStyles");
		SubThemeMacro.addSubTheme("feathers.controls.TextInput", "feathers.themes.steel.components.SteelTextInputStyles");
		SubThemeMacro.addSubTheme("feathers.controls.ToggleButton", "feathers.themes.steel.components.SteelToggleButtonStyles");
		SubThemeMacro.addSubTheme("feathers.controls.ToggleSwitch", "feathers.themes.steel.components.SteelToggleSwitchStyles");
		SubThemeMacro.addSubTheme("feathers.controls.VProgressBar", "feathers.themes.steel.components.SteelVProgressBarStyles");
		SubThemeMacro.addSubTheme("feathers.controls.VScrollBar", "feathers.themes.steel.components.SteelVScrollBarStyles");
		SubThemeMacro.addSubTheme("feathers.controls.VSlider", "feathers.themes.steel.components.SteelVSliderStyles");
	}
}
