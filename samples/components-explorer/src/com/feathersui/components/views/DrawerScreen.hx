package com.feathersui.components.views;

import feathers.controls.Button;
import feathers.controls.Drawer;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class DrawerScreen extends Drawer {
	override private function initialize():Void {
		super.initialize();

		this.createContent();
		this.createDrawer();
	}

	private function createContent():Void {
		var content = new Panel();
		var contentLayout = new VerticalLayout();
		contentLayout.paddingTop = 10.0;
		contentLayout.paddingRight = 10.0;
		contentLayout.paddingBottom = 10.0;
		contentLayout.paddingLeft = 10.0;
		contentLayout.gap = 10.0;
		contentLayout.horizontalAlign = CENTER;
		contentLayout.verticalAlign = MIDDLE;
		content.layout = contentLayout;

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		content.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Drawer";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);

		var openButton = new Button();
		openButton.text = "Open Drawer";
		openButton.addEventListener(TriggerEvent.TRIGGER, openButton_triggerHandler);
		content.addChild(openButton);

		this.content = content;
	}

	private function createDrawer():Void {
		var drawer = new Panel();
		var drawerLayout = new VerticalLayout();
		drawerLayout.paddingTop = 10.0;
		drawerLayout.paddingRight = 10.0;
		drawerLayout.paddingBottom = 10.0;
		drawerLayout.paddingLeft = 10.0;
		drawerLayout.gap = 10.0;
		drawerLayout.horizontalAlign = CENTER;
		drawerLayout.verticalAlign = MIDDLE;
		drawer.layout = drawerLayout;

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		drawer.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "I'm a drawer";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var closeButton = new Button();
		closeButton.text = "Close Drawer";
		closeButton.addEventListener(TriggerEvent.TRIGGER, closeButton_triggerHandler);
		drawer.addChild(closeButton);

		this.drawer = drawer;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function openButton_triggerHandler(event:TriggerEvent):Void {
		this.opened = true;
	}

	private function closeButton_triggerHandler(event:TriggerEvent):Void {
		this.opened = false;
	}
}
