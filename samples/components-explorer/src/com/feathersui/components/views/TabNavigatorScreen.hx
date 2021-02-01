package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.RectangleSkin;
import openfl.events.Event;
import openfl.text.TextFormat;

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
		var header = new Header();
		header.text = "Tab Navigator";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function tabNavigator_changeHandler(event:Event):Void {
		trace("TabNavigator activeItemID change: " + this.navigator.activeItemID);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
