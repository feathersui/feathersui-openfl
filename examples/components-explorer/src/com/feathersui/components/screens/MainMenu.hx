package com.feathersui.components.screens;

import feathers.style.Theme;
import feathers.themes.DefaultTheme;
import openfl.events.MouseEvent;
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
			themeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
				var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
				if (theme != null) {
					theme.darkMode = !theme.darkMode;
				}
			});
			themeButton.layoutData = new AnchorLayoutData(null, 10, null, null, null, 0);
			header.addChild(themeButton);

			return header;
		};

		this.listBox = new ListBox();
		this.listBox.dataProvider = new ArrayCollection([
			{text: "Asset Loader", screenID: ScreenID.ASSET_LOADER}, {text: "Button", screenID: ScreenID.BUTTON}, {text: "Check", screenID: ScreenID.CHECK},
			{text: "Label", screenID: ScreenID.LABEL}, {text: "List Box", screenID: ScreenID.LIST_BOX}, {text: "Panel", screenID: ScreenID.PANEL},
			{text: "Pop Up Manager", screenID: ScreenID.POP_UP_MANAGER}, {text: "Progress Bar", screenID: ScreenID.PROGRESS_BAR},
			{text: "Radio", screenID: ScreenID.RADIO}, {text: "Slider", screenID: ScreenID.SLIDER}, {text: "Text Input", screenID: ScreenID.TEXT_INPUT},
			{text: "Toggle Switch", screenID: ScreenID.TOGGLE_SWITCH},
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
