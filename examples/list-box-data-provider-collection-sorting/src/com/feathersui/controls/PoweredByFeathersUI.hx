/*
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package com.feathersui.controls;

import openfl.net.URLRequest;
import openfl.Lib;
import openfl.events.MouseEvent;
import feathers.controls.Label;
import feathers.controls.AssetLoader;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;

/**
	Displays the Feathers UI logo and links to feathersui.com
**/
class PoweredByFeathersUI extends LayoutGroup {
	public function new() {
		super();

		var layout = new HorizontalLayout();
		layout.verticalAlign = MIDDLE;

		this.layout = layout;
		this.buttonMode = true;
		this.useHandCursor = true;
		this.mouseChildren = false;

		var label = new Label();
		label.text = "Powered by ";
		this.addChild(label);

		var icon = new AssetLoader();
		// <assets id="feathersui-logo" path="assets/img/feathersui-logo.png" embed="false"/>
		icon.source = "feathersui-logo";
		icon.height = 16.0;
		this.addChild(icon);

		this.addEventListener(MouseEvent.CLICK, poweredBy_clickHandler);
	}

	private function poweredBy_clickHandler(event:MouseEvent):Void {
		Lib.navigateToURL(new URLRequest("https://feathersui.com/"), "_blank");
	}
}
