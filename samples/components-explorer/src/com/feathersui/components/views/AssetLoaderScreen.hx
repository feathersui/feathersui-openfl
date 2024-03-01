package com.feathersui.components.views;

import feathers.controls.AssetLoader;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class AssetLoaderScreen extends Panel {
	private var syncAssetLoader:AssetLoader;
	private var asyncAssetLoader:AssetLoader;
	private var urlAssetLoader:AssetLoader;

	override private function initialize():Void {
		super.initialize();
		this.createHeader();

		var layout = new VerticalLayout();
		layout.horizontalAlign = CENTER;
		layout.verticalAlign = MIDDLE;
		layout.gap = 10.0;
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		this.layout = layout;

		this.syncAssetLoader = new AssetLoader();
		// uses openfl.Assets.getBitmapData() to get an embedded asset by ID
		// <assets id="haxe" path="assets/img/haxe.png"/>
		this.syncAssetLoader.source = "haxe";
		this.syncAssetLoader.sourceScale = 0.5;
		this.addChild(this.syncAssetLoader);
		var syncLabel = new Label();
		syncLabel.text = "Asset (Sync)";
		this.addChild(syncLabel);

		this.asyncAssetLoader = new AssetLoader();
		// uses openfl.Assets.loadBitmap() to get a non-embedded asset by ID
		// <assets id="openfl" path="assets/img/openfl.png" embed="false"/>
		this.asyncAssetLoader.source = "openfl";
		this.asyncAssetLoader.sourceScale = 0.5;
		this.asyncAssetLoader.addEventListener(Event.COMPLETE, asyncAssetLoader_completeHandler);
		this.addChild(this.asyncAssetLoader);
		var asyncLabel = new Label();
		asyncLabel.text = "Asset (Async)";
		this.addChild(asyncLabel);

		this.urlAssetLoader = new AssetLoader();
		// uses openfl.display.Loader to load an image from the web
		this.urlAssetLoader.source = "https://feathersui.com/samples/haxe-openfl/components-explorer/images/feathersui-icon.png";
		this.urlAssetLoader.sourceScale = 0.5;
		this.urlAssetLoader.addEventListener(Event.COMPLETE, urlAssetLoader_completeHandler);
		this.addChild(this.urlAssetLoader);
		var urlLabel = new Label();
		urlLabel.text = "URL (Async)";
		this.addChild(urlLabel);
	}

	private function createHeader():Void {
		var header = new Header();
		header.text = "Asset Loader";
		this.header = header;

		var backButton = new Button();
		backButton.text = "Back";
		backButton.addEventListener(TriggerEvent.TRIGGER, backButton_triggerHandler);
		header.leftView = backButton;
	}

	private function backButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	private function asyncAssetLoader_completeHandler(event:Event):Void {
		trace("async asset complete: " + this.asyncAssetLoader.source);
	}

	private function urlAssetLoader_completeHandler(event:Event):Void {
		trace("URL asset complete: " + this.urlAssetLoader.source);
	}
}
