package com.feathersui.hn.views;

import feathers.controls.Label;
import feathers.controls.ScrollContainer;
import feathers.layout.VerticalLayout;

class NotFoundView extends ScrollContainer {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.gap = 8.0;
		viewLayout.setPadding(8.0);
		layout = viewLayout;

		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "404 Not found";
		title.wordWrap = true;
		addChild(title);
	}
}
