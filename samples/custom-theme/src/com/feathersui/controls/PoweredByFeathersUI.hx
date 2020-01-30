/*
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
import feathers.controls.TextCallout;

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

		this.addEventListener(MouseEvent.ROLL_OVER, poweredBy_rollOverHandler);
		this.addEventListener(MouseEvent.ROLL_OUT, poweredBy_rollOutHandler);
		this.addEventListener(MouseEvent.CLICK, poweredBy_clickHandler);
	}

	private var callout:TextCallout;

	private function poweredBy_rollOverHandler(event:MouseEvent):Void {
		this.callout = TextCallout.show("Learn more at feathersui.com", this, null, false);
	}

	private function poweredBy_rollOutHandler(event:MouseEvent):Void {
		if (this.callout != null) {
			this.callout.close();
		}
	}

	private function poweredBy_clickHandler(event:MouseEvent):Void {
		Lib.navigateToURL(new URLRequest("https://feathersui.com/"), "_blank");
	}
}
