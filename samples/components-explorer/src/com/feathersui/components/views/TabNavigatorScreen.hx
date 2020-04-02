package com.feathersui.components.views;

import openfl.text.TextFormat;
import openfl.text.TextField;
import feathers.skins.RectangleSkin;
import feathers.controls.navigators.TabNavigator;
import feathers.controls.navigators.TabItem;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.events.Event;

class TabNavigatorScreen extends Panel {
	private var navigator:TabNavigator;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		this.layout = new AnchorLayout();

		this.navigator = new TabNavigator();
		this.navigator.dataProvider = new ArrayCollection([
			this.createTab("Tab 1", 0x993333),
			this.createTab("Tab 2", 0x339933),
			this.createTab("Tab 3", 0x333399),
		]);
		this.navigator.layoutData = AnchorLayoutData.fill();
		this.navigator.addEventListener(Event.CHANGE, tabNavigator_changeHandler);
		this.addChild(this.navigator);
	}

	private function createTab(text:String, color:UInt):TabItem {
		var content = new LayoutGroup();
		content.layout = new AnchorLayout();
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(color);
		content.backgroundSkin = backgroundSkin;
		var label = new Label();
		label.textFormat = new TextFormat("_sans", 20, 0xffffff);
		label.text = text;
		label.layoutData = AnchorLayoutData.center();
		content.addChild(label);
		return TabItem.withDisplayObject(text, content);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Tab Navigator";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function tabNavigator_changeHandler(event:Event):Void {
		trace("TabNavigator activeItemID change: " + this.navigator.activeItemID);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
