package com.feathersui.components.views;

import feathers.controls.ScrollPolicy;
import feathers.style.IDarkModeTheme;
import feathers.events.FeathersEvent;
import feathers.style.Theme;
import openfl.events.Event;
import com.feathersui.components.ViewPaths;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.controls.ListView;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.layout.AnchorLayoutData;

class MainMenu extends Panel {
	private var listView:ListView;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Feathers UI";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var themeButton = new Button();
			themeButton.text = "Theme";
			themeButton.addEventListener(FeathersEvent.TRIGGERED, function(event:FeathersEvent):Void {
				var theme = Theme.getTheme();
				if (!Std.is(theme, IDarkModeTheme)) {
					return;
				}
				var darkModeTheme = cast(theme, IDarkModeTheme);
				darkModeTheme.darkMode = !darkModeTheme.darkMode;
			});
			themeButton.layoutData = new AnchorLayoutData(null, 10, null, null, null, 0);
			header.addChild(themeButton);

			return header;
		};

		this.listView = new ListView();
		this.listView.dataProvider = new ArrayCollection([
			new MenuItem("Asset Loader", ViewPaths.ASSET_LOADER), new MenuItem("Button", ViewPaths.BUTTON), new MenuItem("Callout", ViewPaths.CALLOUT),
			new MenuItem("Check", ViewPaths.CHECK), new MenuItem("Combo Box", ViewPaths.COMBO_BOX), new MenuItem("Label", ViewPaths.LABEL),
			new MenuItem("List View", ViewPaths.LIST_VIEW), new MenuItem("Panel", ViewPaths.PANEL), new MenuItem("Pop Up List", ViewPaths.POP_UP_LIST),
			new MenuItem("Pop Up Manager", ViewPaths.POP_UP_MANAGER), new MenuItem("Progress Bar", ViewPaths.PROGRESS_BAR),
			new MenuItem("Radio", ViewPaths.RADIO), new MenuItem("Slider", ViewPaths.SLIDER), new MenuItem("Tab Bar", ViewPaths.TAB_BAR),
			new MenuItem("Text Input", ViewPaths.TEXT_INPUT), new MenuItem("Toggle Switch", ViewPaths.TOGGLE_SWITCH),
		]);
		this.listView.layoutData = AnchorLayoutData.fill();
		this.listView.addEventListener(Event.CHANGE, list_changeHandler);
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

	private function list_changeHandler(event:Event):Void {
		var selectedItem = this.listView.selectedItem;
		this.selectedViewPaths = selectedItem.screenID;
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
