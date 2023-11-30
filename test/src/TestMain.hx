/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import openfl.display.Sprite;
import utest.Runner;
import utest.ui.common.PackageResult;
import utest.ui.common.ResultAggregator;
#if (html5 && !headless_html5)
import utest.ui.text.HtmlReport;
#end

class TestMain extends Sprite {
	public function new() {
		super();

		var runner = new Runner();
		#if !flash
		// // these tests often timeout on CI when running in Flash/AIR
		runner.addCase(new feathers.controls.AssetLoaderTest());
		runner.addCase(new feathers.utils.LongPressTest());
		#end
		runner.addCase(new feathers.controls.AlertTest());
		runner.addCase(new feathers.controls.BasicButtonMeasurementTest());
		runner.addCase(new feathers.controls.BasicButtonTest());
		runner.addCase(new feathers.controls.BasicToggleButtonTest());
		runner.addCase(new feathers.controls.BasicToggleButtonMeasurementTest());
		runner.addCase(new feathers.controls.ButtonTest());
		runner.addCase(new feathers.controls.ButtonMeasurementTest());
		runner.addCase(new feathers.controls.ButtonBarTest());
		runner.addCase(new feathers.controls.CalloutTest());
		runner.addCase(new feathers.controls.ComboBoxTest());
		runner.addCase(new feathers.controls.DatePickerTest());
		runner.addCase(new feathers.controls.DrawerTest());
		runner.addCase(new feathers.controls.FormTest());
		runner.addCase(new feathers.controls.GridViewTest());
		runner.addCase(new feathers.controls.GroupListViewTest());
		runner.addCase(new feathers.controls.HeaderTest());
		runner.addCase(new feathers.controls.HProgressBarTest());
		runner.addCase(new feathers.controls.HScrollBarTest());
		runner.addCase(new feathers.controls.HSliderTest());
		runner.addCase(new feathers.controls.dataRenderers.HierarchicalItemRendererTest());
		runner.addCase(new feathers.controls.dataRenderers.ItemRendererTest());
		runner.addCase(new feathers.controls.dataRenderers.ItemRendererMeasurementTest());
		runner.addCase(new feathers.controls.LabelTest());
		runner.addCase(new feathers.controls.LabelMeasurementTest());
		runner.addCase(new feathers.controls.LayoutGroupTest());
		runner.addCase(new feathers.controls.LayoutGroupMeasurementTest());
		runner.addCase(new feathers.controls.ListViewTest());
		runner.addCase(new feathers.controls.NumericStepperTest());
		runner.addCase(new feathers.controls.PageIndicatorTest());
		runner.addCase(new feathers.controls.PanelTest());
		runner.addCase(new feathers.controls.PanelMeasurementTest());
		runner.addCase(new feathers.controls.PopUpDatePickerTest());
		runner.addCase(new feathers.controls.PopUpListViewTest());
		runner.addCase(new feathers.controls.RadioTest());
		runner.addCase(new feathers.controls.navigators.PageNavigatorTest());
		runner.addCase(new feathers.controls.navigators.StackNavigatorTest());
		runner.addCase(new feathers.controls.navigators.TabNavigatorTest());
		runner.addCase(new feathers.controls.ScrollContainerTest());
		runner.addCase(new feathers.controls.ScrollContainerFixedScrollBarsTest());
		runner.addCase(new feathers.controls.ScrollContainerFloatingScrollBarsTest());
		runner.addCase(new feathers.controls.ScrollContainerMeasurementTest());
		runner.addCase(new feathers.controls.TabBarTest());
		runner.addCase(new feathers.controls.TextInputTest());
		runner.addCase(new feathers.controls.ToggleButtonTest());
		runner.addCase(new feathers.controls.ToggleButtonMeasurementTest());
		runner.addCase(new feathers.controls.ToggleSwitchTest());
		runner.addCase(new feathers.controls.TreeGridViewTest());
		runner.addCase(new feathers.controls.TreeViewTest());
		runner.addCase(new feathers.controls.VProgressBarTest());
		runner.addCase(new feathers.controls.VScrollBarTest());
		runner.addCase(new feathers.controls.VSliderTest());
		runner.addCase(new feathers.core.ComponentLifecycleTest());
		runner.addCase(new feathers.core.DefaultPopUpManagerTest());
		runner.addCase(new feathers.core.FocusManagerTest());
		runner.addCase(new feathers.core.FocusManagerComboBoxTest());
		runner.addCase(new feathers.core.FocusManagerNumericStepperTest());
		runner.addCase(new feathers.core.FocusManagerPopUpListViewTest());
		runner.addCase(new feathers.core.FocusManagerTextAreaTest());
		runner.addCase(new feathers.core.FocusManagerTextInputTest());
		runner.addCase(new feathers.core.InvalidationTest());
		runner.addCase(new feathers.core.MinAndMaxDimensionsTest());
		runner.addCase(new feathers.core.PopUpManagerTest());
		runner.addCase(new feathers.core.RestrictedStyleTest());
		runner.addCase(new feathers.core.ScaleTest());
		runner.addCase(new feathers.core.ToggleGroupTest());
		runner.addCase(new feathers.data.ArrayCollectionTest());
		runner.addCase(new feathers.data.ArrayHierarchicalCollectionTest());
		runner.addCase(new feathers.data.TreeCollectionTest());
		runner.addCase(new feathers.layout.AnchorLayoutTest());
		runner.addCase(new feathers.layout.FlowRowsLayoutTest());
		runner.addCase(new feathers.layout.HorizontalDistributedLayoutTest());
		runner.addCase(new feathers.layout.HorizontalLayoutTest());
		runner.addCase(new feathers.layout.HorizontalListLayoutTest());
		runner.addCase(new feathers.layout.MeasurementsTest());
		runner.addCase(new feathers.layout.TiledRowsLayoutTest());
		runner.addCase(new feathers.layout.TiledRowsListLayoutTest());
		runner.addCase(new feathers.layout.VerticalDistributedLayoutTest());
		runner.addCase(new feathers.layout.VerticalLayoutTest());
		runner.addCase(new feathers.layout.VerticalListFixedRowLayoutTest());
		runner.addCase(new feathers.layout.VerticalListLayoutTest());
		runner.addCase(new feathers.style.ClassVariantStyleProviderTest());
		runner.addCase(new feathers.style.FunctionStyleProviderTest());
		runner.addCase(new feathers.style.StyleProviderAndVariantTest());
		runner.addCase(new feathers.style.StyleProviderRestrictedStyleTest());
		runner.addCase(new feathers.style.ThemeTest());
		runner.addCase(new feathers.themes.DefaultThemeTest());
		runner.addCase(new feathers.utils.ExclusivePointerTest());
		runner.addCase(new feathers.utils.PointerTriggerTest());
		runner.addCase(new feathers.utils.PopUpUtilTest());
		#if (html5 && !headless_html5)
		if (js.Syntax.code("typeof window !== 'undefined'")) {
			new HtmlReport(runner, true);
		}
		#else
		new NoExitPrintReport(runner);
		#end
		var aggregator = new ResultAggregator(runner, true);
		aggregator.onComplete.add(aggregator_onComplete);
		runner.run();
	}

	private function aggregator_onComplete(result:PackageResult):Void {
		var stats = result.stats;
		var exitCode = stats.isOk ? 0 : 1;
		var message = 'Successes: ${stats.successes}, Failures: ${stats.failures}, Errors: ${stats.errors}, Warnings: ${stats.warnings}, Skipped: ${stats.ignores}';
		#if html5
		if (exitCode == 0) {
			js.html.Console.info(message);
		} else {
			js.html.Console.error(message);
		}
		#else
		trace(message);
		#end

		#if sys
		Sys.exit(exitCode);
		#elseif html5
		#if headless_html5
		Reflect.setField(js.Lib.global, "utestResult", result);
		#else
		trace("Tests complete. You may close this window.");
		#end
		#elseif air
		flash.desktop.NativeApplication.nativeApplication.exit(exitCode);
		#elseif flash
		if (flash.system.Security.sandboxType == "localTrusted") {
			flash.system.System.exit(exitCode);
		} else {
			flash.Lib.fscommand("quit");
		}
		#end
	}
}
