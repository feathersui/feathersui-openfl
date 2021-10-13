package com.feathersui.components.views;

import com.feathersui.components.ViewPaths;
import feathers.controls.Button;
import feathers.controls.GroupListView;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.GroupListViewEvent;
import feathers.events.ScrollEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;
import openfl.events.Event;

class MainMenu extends Panel {
	public function new() {
		super();
	}

	private var listView:GroupListView;

	public var savedScrollY = 0.0;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		var menuItems = new ArrayHierarchicalCollection([
			// @formatter:off
			new MenuItem("Basic Controls", null, [
				new MenuItem("Asset Loader", ViewPaths.ASSET_LOADER),
				new MenuItem("Button", ViewPaths.BUTTON),
				new MenuItem("Check", ViewPaths.CHECK),
				new MenuItem("Date Picker", ViewPaths.DATE_PICKER),
				new MenuItem("Header", ViewPaths.HEADER),
				new MenuItem("Label", ViewPaths.LABEL),
				new MenuItem("Numeric Stepper", ViewPaths.NUMERIC_STEPPER),
				new MenuItem("Page Indicator", ViewPaths.PAGE_INDICATOR),
				new MenuItem("Pop Up Date Picker", ViewPaths.POP_UP_DATE_PICKER),
				new MenuItem("Progress Bar", ViewPaths.PROGRESS_BAR),
				new MenuItem("Radio", ViewPaths.RADIO),
				new MenuItem("Slider", ViewPaths.SLIDER),
				new MenuItem("Text Area", ViewPaths.TEXT_AREA),
				new MenuItem("Text Input", ViewPaths.TEXT_INPUT),
				new MenuItem("Toggle Switch", ViewPaths.TOGGLE_SWITCH),
			]),
			new MenuItem("Simple Containers", null, [
				new MenuItem("Divided Box (Horizontal)", ViewPaths.HORIZONTAL_DIVIDED_BOX),
				new MenuItem("Divided Box (Vertical)", ViewPaths.VERTICAL_DIVIDED_BOX),
				new MenuItem("Form", ViewPaths.FORM),
				new MenuItem("Layout Group", ViewPaths.LAYOUT_GROUP),
				new MenuItem("Panel", ViewPaths.PANEL),
				new MenuItem("Scroll Container", ViewPaths.SCROLL_CONTAINER),
			]),
			new MenuItem("Data Containers", null, [
				new MenuItem("Button Bar", ViewPaths.BUTTON_BAR),
				new MenuItem("Combo Box", ViewPaths.COMBO_BOX),
				new MenuItem("Grid View", ViewPaths.GRID_VIEW),
				new MenuItem("Group List View", ViewPaths.GROUP_LIST_VIEW),
				new MenuItem("List View", ViewPaths.LIST_VIEW),
				new MenuItem("Pop Up List View", ViewPaths.POP_UP_LIST_VIEW),
				new MenuItem("Tab Bar", ViewPaths.TAB_BAR),
				new MenuItem("Tree View", ViewPaths.TREE_VIEW),
			]),
			new MenuItem("Navigators", null, [
				new MenuItem("Page Navigator", ViewPaths.PAGE_NAVIGATOR),
				new MenuItem("Stack Navigator", ViewPaths.STACK_NAVIGATOR),
				new MenuItem("Tab Navigator", ViewPaths.TAB_NAVIGATOR)
			]),
			new MenuItem("Skins", null, [
				new MenuItem("Circle Skin", ViewPaths.CIRCLE_SKIN),
				new MenuItem("Ellipse Skin", ViewPaths.ELLIPSE_SKIN),
				new MenuItem("Pill Skin", ViewPaths.PILL_SKIN),
				new MenuItem("Rectangle Skin", ViewPaths.RECTANGLE_SKIN),
				new MenuItem("Tab Skin", ViewPaths.TAB_SKIN),
				new MenuItem("Triangle Skin", ViewPaths.TRIANGLE_SKIN),
			]),
			new MenuItem("Miscellaneous", null, [
				new MenuItem("Alert", ViewPaths.ALERT),
				new MenuItem("Callout", ViewPaths.CALLOUT),
				new MenuItem("Drawer", ViewPaths.DRAWER),
				new MenuItem("Item Renderer", ViewPaths.ITEM_RENDERER),
				new MenuItem("Pop Up Manager", ViewPaths.POP_UP_MANAGER),
				new MenuItem("Text Callout", ViewPaths.TEXT_CALLOUT)
			]),
			// @formatter:on
		]);
		menuItems.itemToChildren = item -> item.children;

		this.listView = new GroupListView();
		this.listView.dataProvider = menuItems;
		this.listView.scrollY = this.savedScrollY;
		this.listView.layoutData = AnchorLayoutData.fill();
		this.listView.addEventListener(ScrollEvent.SCROLL, listView_scrollHandler);
		this.listView.addEventListener(GroupListViewEvent.ITEM_TRIGGER, listView_itemTriggerHandler);
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
		var header = new Header();
		header.text = "Feathers UI";
		this.header = header;

		var themeButton = new Button();
		themeButton.text = "Theme";
		themeButton.addEventListener(TriggerEvent.TRIGGER, function(event:TriggerEvent):Void {
			var theme = Theme.getTheme();
			if (!(theme is IDarkModeTheme)) {
				return;
			}
			var darkModeTheme = cast(theme, IDarkModeTheme);
			darkModeTheme.darkMode = !darkModeTheme.darkMode;
		});
		header.rightView = themeButton;
	}

	private function listView_scrollHandler(event:ScrollEvent):Void {
		// save the current scroll position to be used if we navigate away from
		// this view and return again later
		this.savedScrollY = this.listView.scrollY;
	}

	private function listView_itemTriggerHandler(event:GroupListViewEvent):Void {
		var triggeredItem = event.state.data;
		if (triggeredItem.screenID == null) {
			return;
		}
		this.selectedViewPaths = triggeredItem.screenID;
	}
}

private class MenuItem {
	public function new(title:String, screenID:String, ?children:Array<MenuItem>) {
		this.title = title;
		this.screenID = screenID;
		this.children = children;
	}

	public var title:String;
	public var screenID:String;
	public var children:Array<MenuItem>;

	@:keep
	public function toString() {
		return this.title;
	}
}
