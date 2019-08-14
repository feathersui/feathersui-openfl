package com.feathersui.components.screens;

import openfl.events.Event;
import openfl.events.MouseEvent;
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
	private var assetLoader:AssetLoader;
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
			backButton.addEventListener(MouseEvent.CLICK, backButton_clickHandler);
			header.addChild(backButton);

			return header;
		};

		this.assetLoader = new AssetLoader();
		// uses openfl.Assets.getBitmapData() to get an asset by ID
		this.assetLoader.source = "favicon";
		this.addChild(this.assetLoader);

		this.urlLoader = new AssetLoader();
		// may also load an image from a URL
		this.urlLoader.source = "https://feathersui.com/examples/components-explorer/images/feathersui-icon.png";
		this.addChild(this.urlLoader);
	}

	private function backButton_clickHandler(event:MouseEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
