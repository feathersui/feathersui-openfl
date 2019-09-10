package com.feathersui.components.screens;

import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Label;
import feathers.layout.AnchorLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.controls.AssetLoader;
import feathers.controls.Panel;

class AssetLoaderScreen extends Panel {
	private var syncAssetLoader:AssetLoader;
	private var asyncAssetLoader:AssetLoader;
	private var urlLoader:AssetLoader;

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.gap = 20;
		this.layout = layout;

		this.headerFactory = function():LayoutGroup {
			var header = new LayoutGroup();
			header.variant = LayoutGroup.VARIANT_TOOL_BAR;
			header.layout = new AnchorLayout();

			var headerTitle = new Label();
			headerTitle.variant = Label.VARIANT_HEADING;
			headerTitle.text = "Asset Loader";
			headerTitle.layoutData = AnchorLayoutData.center();
			header.addChild(headerTitle);

			var backButton = new Button();
			backButton.text = "Back";
			backButton.layoutData = new AnchorLayoutData(null, null, null, 10, null, 0);
			backButton.addEventListener(FeathersEvent.TRIGGERED, backButton_triggeredHandler);
			header.addChild(backButton);

			return header;
		};

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
		this.urlLoader.source = "https://feathersui.com/examples/components-explorer/images/feathersui-icon.png";
		this.addChild(this.urlLoader);
	}

	private function backButton_triggeredHandler(event:FeathersEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
