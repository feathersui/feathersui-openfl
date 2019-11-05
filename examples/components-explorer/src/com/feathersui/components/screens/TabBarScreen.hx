package com.feathersui.components.screens;

import feathers.controls.ToggleButton;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.TabBarItemState;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.layout.AnchorLayoutData;
import feathers.data.ArrayCollection;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.events.FeathersEvent;
import feathers.controls.TabBar;
import openfl.events.Event;
import feathers.controls.Panel;

class TabBarScreen extends Panel {
	private var tabBar:TabBar;

	override private function initialize():Void {
		super.initialize();

		this.layout = new AnchorLayout();

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Tab Bar";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

		var items = [];
		for (i in 0...3) {
			items[i] = {text: "Tab " + (i + 1)};
		}

		this.tabBar = new TabBar();
		this.tabBar.dataProvider = new ArrayCollection(items);
		this.tabBar.buttonRecycler = new DisplayObjectRecycler(ToggleButton, (button:ToggleButton, state:TabBarItemState) -> {
			button.text = state.text;
		});
		this.tabBar.itemToText = (data:Dynamic) ->
		{
			return data.text;
		};
		this.tabBar.layoutData = AnchorLayoutData.center();
		this.tabBar.addEventListener(Event.CHANGE, tabBar_changeHandler);
		this.addChild(this.tabBar);
	}

	private function tabBar_changeHandler(event:Event):Void {
		trace("TabBar selectedIndex change: " + this.tabBar.selectedIndex);
	}

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
