package com.feathersui.components.views;

import com.feathersui.components.ViewPaths;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;
import openfl.events.Event;

class MainMenu extends Panel {
	private var listView:ListView;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.listView = new ListView();
		this.listView.dataProvider = new ArrayCollection([
			// @formatter:off
			new MenuItem("Asset Loader", ViewPaths.ASSET_LOADER),
			new MenuItem("Button", ViewPaths.BUTTON),
			new MenuItem("Callout", ViewPaths.CALLOUT),
			new MenuItem("Check", ViewPaths.CHECK),
			new MenuItem("Combo Box", ViewPaths.COMBO_BOX),
			new MenuItem("Grid View", ViewPaths.GRID_VIEW),
			new MenuItem("Label", ViewPaths.LABEL),
			new MenuItem("List View", ViewPaths.LIST_VIEW),
			new MenuItem("Page Indicator", ViewPaths.PAGE_INDICATOR),
			new MenuItem("Page Navigator", ViewPaths.PAGE_NAVIGATOR),
			new MenuItem("Panel", ViewPaths.PANEL),
			new MenuItem("Pop Up List View", ViewPaths.POP_UP_LIST_VIEW),
			new MenuItem("Pop Up Manager", ViewPaths.POP_UP_MANAGER),
			new MenuItem("Progress Bar", ViewPaths.PROGRESS_BAR),
			new MenuItem("Radio", ViewPaths.RADIO),
			new MenuItem("Slider", ViewPaths.SLIDER),
			new MenuItem("Tab Bar", ViewPaths.TAB_BAR),
			new MenuItem("Tab Navigator", ViewPaths.TAB_NAVIGATOR),
			new MenuItem("Text Area", ViewPaths.TEXT_AREA),
			new MenuItem("Text Input", ViewPaths.TEXT_INPUT),
			new MenuItem("Toggle Switch", ViewPaths.TOGGLE_SWITCH),
			new MenuItem("Tree View", ViewPaths.TREE_VIEW),
			// @formatter:on
		]);
		this.listView.layoutData = AnchorLayoutData.fill();
		this.listView.addEventListener(ListViewEvent.ITEM_TRIGGER, listView_itemTriggerHandler);
		this.addChild(this.listView);
	}

	public var selectedViewPaths(default, set):String = null;

	private function set_selectedViewPaths(value:String):String {
		if (this.selectedViewPaths == value) {
			return this.selectedViewPaths;
		}
		this.selectedViewPaths = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.selectedViewPaths;
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Feathers UI";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var themeButton = new Button();
		themeButton.text = "Theme";
		themeButton.addEventListener(TriggerEvent.TRIGGER, function(event:TriggerEvent):Void {
			var theme = Theme.getTheme();
			if (!Std.is(theme, IDarkModeTheme)) {
				return;
			}
			var darkModeTheme = cast(theme, IDarkModeTheme);
			darkModeTheme.darkMode = !darkModeTheme.darkMode;
		});
		themeButton.layoutData = AnchorLayoutData.middleRight(0.0, 10.0);
		header.addChild(themeButton);
	}

	private function listView_itemTriggerHandler(event:ListViewEvent):Void {
		var triggeredItem = event.state.data;
		this.selectedViewPaths = triggeredItem.screenID;
	}
}

private class MenuItem {
	public function new(title:String, screenID:String) {
		this.title = title;
		this.screenID = screenID;
	}

	public var title:String;
	public var screenID:String;

	@:keep
	public function toString() {
		return this.title;
	}
}
