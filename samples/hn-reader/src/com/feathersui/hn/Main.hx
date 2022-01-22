package com.feathersui.hn;

import com.feathersui.hn.views.ReaderView;
import feathers.controls.Application;

class Main extends Application {
	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		var navView = new ReaderView();
		navView.autoSizeMode = STAGE;
		addChild(navView);
	}
}
