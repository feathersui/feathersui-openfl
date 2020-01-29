package com.feathersui.components.views;

import feathers.controls.AssetLoader;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class AssetLoaderScreen extends Panel {
	private var syncAssetLoader:AssetLoader;
	private var asyncAssetLoader:AssetLoader;
	private var urlLoader:AssetLoader;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 20.0;
		this.layout = layout;

		this.syncAssetLoader = new AssetLoader();
		// uses openfl.Assets.getBitmapData() to get an embedded asset by ID
		// <assets id="haxe" path="assets/img/haxe.png"/>
		this.syncAssetLoader.source = "haxe";
		this.addChild(this.syncAssetLoader);

		this.asyncAssetLoader = new AssetLoader();
		// uses openfl.Assets.loadBitmap() to get a non-embedded asset by ID
		// <assets id="openfl" path="assets/img/openfl.png" embed="false"/>
		this.asyncAssetLoader.source = "openfl";
		this.addChild(this.asyncAssetLoader);

		this.urlLoader = new AssetLoader();
		// uses openfl.display.Loader to load an image from the web
		this.urlLoader.source = "https://feathersui.com/samples/haxe-openfl/components-explorer/images/feathersui-icon.png";
		this.addChild(this.urlLoader);
	}

	private function createHeader():Void {
		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		header.layout = new AnchorLayout();
		this.header = header;

		var headerTitle = new Label();
		headerTitle.variant = Label.VARIANT_HEADING;
		headerTitle.text = "Asset Loader";
		headerTitle.layoutData = AnchorLayoutData.center();
		header.addChild(headerTitle);

		var backButton = new Button();
		backButton.text = "Back";
		backButton.layoutData = AnchorLayoutData.middleLeft(0.0, 10.0);
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.addChild(backButton);
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
