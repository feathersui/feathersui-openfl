package com.feathersui.hn.views;

import feathers.controls.Label;
import feathers.controls.ScrollContainer;
import feathers.layout.VerticalLayout;

class AboutView extends ScrollContainer {
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
		title.text = "About";
		title.wordWrap = true;
		addChild(title);

		var description = new Label();
		description.htmlText = '<p>A Hacker News reader created with <a href="https://feathersui.com/"><u>Feathers UI</u></a>.</p>\n<p>Data provided by <a href="https://github.com/tastejs/hacker-news-pwas/blob/master/docs/api.md"><u>HNPWA API</u></a>, a fast, CDN delivered, aggregated Hacker News API.</p>';
		description.wordWrap = true;
		addChild(description);
	}
}
