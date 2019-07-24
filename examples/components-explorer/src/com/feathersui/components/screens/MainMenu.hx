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
import feathers.layout.AnchorLayoutData;

class MainMenu extends LayoutGroup {
	private var header:LayoutGroup;
	private var headerTitle:Label;
	private var themeButton:Button;
	private var list:ListBox;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.header = new LayoutGroup();
		this.header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		this.header.layout = new AnchorLayout();
		this.header.layoutData = new AnchorLayoutData(0, 0, null, 0);
		this.addChild(this.header);

		this.headerTitle = new Label();
		this.headerTitle.variant = Label.VARIANT_HEADING;
		this.headerTitle.text = "Feathers UI";
		this.headerTitle.layoutData = AnchorLayoutData.center();
		this.header.addChild(this.headerTitle);

		this.themeButton = new Button();
		this.themeButton.text = "Theme";
		this.themeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):Void {
			var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
			if (theme != null) {
				theme.darkMode = !theme.darkMode;
			}
		});
		this.themeButton.layoutData = new AnchorLayoutData(null, 10, null, null, null, 0);
		this.header.addChild(this.themeButton);

		this.list = new ListBox();
		this.list.dataProvider = new ArrayCollection([
			{text: "Button", screenID: ScreenID.BUTTON},
			{text: "Check", screenID: ScreenID.CHECK},
			{text: "Label", screenID: ScreenID.LABEL},
			{text: "List Box", screenID: ScreenID.LIST_BOX},
			{text: "Progress Bar", screenID: ScreenID.PROGRESS_BAR},
			{text: "Radio", screenID: ScreenID.RADIO},
			{text: "Slider", screenID: ScreenID.SLIDER},
			{text: "Text Input", screenID: ScreenID.TEXT_INPUT},
			{text: "Toggle Switch", screenID: ScreenID.TOGGLE_SWITCH},
		]);
		this.list.layoutData = new AnchorLayoutData(44, 0, 0, 0);
		this.list.addEventListener(Event.CHANGE, list_changeHandler);
		this.addChild(this.list);
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
		var selectedItem = this.list.selectedItem;
		this.selectedScreenID = selectedItem.screenID;
	}
}
