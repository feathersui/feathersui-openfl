package com.feathersui.components.screens;

import feathers.controls.ScrollPolicy;
import feathers.style.IDarkModeTheme;
import feathers.events.FeathersEvent;
import feathers.style.Theme;
import openfl.events.Event;
import com.feathersui.components.ScreenID;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.controls.ListBox;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.layout.AnchorLayoutData;

class MainMenu extends Panel {
	private var listBox:ListBox;

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

		this.listBox = new ListBox();
		this.listBox.dataProvider = new ArrayCollection([
			new MenuItem("Asset Loader", ScreenID.ASSET_LOADER), new MenuItem("Button", ScreenID.BUTTON), new MenuItem("Callout", ScreenID.CALLOUT),
			new MenuItem("Check", ScreenID.CHECK), new MenuItem("Combo Box", ScreenID.COMBO_BOX), new MenuItem("Label", ScreenID.LABEL),
			new MenuItem("List Box", ScreenID.LIST_BOX), new MenuItem("Panel", ScreenID.PANEL), new MenuItem("Pop Up List", ScreenID.POP_UP_LIST),
			new MenuItem("Pop Up Manager", ScreenID.POP_UP_MANAGER), new MenuItem("Progress Bar", ScreenID.PROGRESS_BAR),
			new MenuItem("Radio", ScreenID.RADIO), new MenuItem("Slider", ScreenID.SLIDER), new MenuItem("Tab Bar", ScreenID.TAB_BAR),
			new MenuItem("Text Input", ScreenID.TEXT_INPUT), new MenuItem("Toggle Switch", ScreenID.TOGGLE_SWITCH),
		]);
		this.listBox.layoutData = AnchorLayoutData.fill();
		this.listBox.addEventListener(Event.CHANGE, list_changeHandler);
		this.addChild(this.listBox);
	}

	public var selectedScreenID(default, set):String = null;

	private function set_selectedScreenID(value:String):String {
		if (this.selectedScreenID == value) {
			return this.selectedScreenID;
		}
		this.selectedScreenID = value;
		this.dispatchEvent(new Event(Event.CHANGE));
		return this.selectedScreenID;
	}

	private function list_changeHandler(event:Event):Void {
		var selectedItem = this.listBox.selectedItem;
		this.selectedScreenID = selectedItem.screenID;
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
