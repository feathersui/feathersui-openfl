/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.RectangleSkin;
import openfl.display.Shape;
import openfl.events.MouseEvent;
import openfl.events.Event;
import feathers.controls.BasicButton;
import feathers.events.FeathersEvent;
import utest.Assert;
import utest.Test;

@:keep
class BasicButtonMeasurementTest extends Test {
	private static final SHAPE_WIDTH = 10.0;
	private static final SHAPE_HEIGHT = 12.0;
	private static final BACKGROUND_WIDTH = 30.0;
	private static final BACKGROUND_HEIGHT = 32.0;
	private static final BACKGROUND_MIN_WIDTH = 20.0;
	private static final BACKGROUND_MIN_HEIGHT = 18.0;
	private static final BACKGROUND_MAX_WIDTH = 50.0;
	private static final BACKGROUND_MAX_HEIGHT = 45.0;

	private var _button:BasicButton;

	public function new() {
		super();
	}

	public function setup():Void {
		this._button = new BasicButton();
		TestMain.openfl_root.addChild(this._button);
	}

	public function teardown():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function addShapeBackground():Void {
		var skin = new Shape();
		skin.graphics.beginFill(0xff00ff);
		skin.graphics.drawRect(0.0, 0.0, SHAPE_WIDTH, SHAPE_HEIGHT);
		skin.graphics.endFill();
		this._button.backgroundSkin = skin;
	}

	private function addRectangleSkinBackground():Void {
		var skin = new RectangleSkin();
		skin.width = BACKGROUND_WIDTH;
		skin.height = BACKGROUND_HEIGHT;
		skin.minWidth = BACKGROUND_MIN_WIDTH;
		skin.minHeight = BACKGROUND_MIN_HEIGHT;
		skin.maxWidth = BACKGROUND_MAX_WIDTH;
		skin.maxHeight = BACKGROUND_MAX_HEIGHT;
		this._button.backgroundSkin = skin;
	}

	public function testMeasurementsWithNoBackgroundSkin():Void {
		this._button.validateNow();

		Assert.equals(0.0, this._button.width);
		Assert.equals(0.0, this._button.height);
		Assert.equals(0.0, this._button.minWidth);
		Assert.equals(0.0, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	public function testMeasurementsWithShapeBackgroundSkin():Void {
		this.addShapeBackground();
		this._button.validateNow();

		Assert.equals(SHAPE_WIDTH, this._button.width);
		Assert.equals(SHAPE_HEIGHT, this._button.height);
		Assert.equals(SHAPE_WIDTH, this._button.minWidth);
		Assert.equals(SHAPE_HEIGHT, this._button.minHeight);
		Assert.equals(SHAPE_WIDTH, this._button.maxWidth);
		Assert.equals(SHAPE_HEIGHT, this._button.maxHeight);
	}

	public function testMeasurementsWithRectangleSkinBackgroundSkin():Void {
		this.addRectangleSkinBackground();
		this._button.validateNow();

		Assert.equals(BACKGROUND_WIDTH, this._button.width);
		Assert.equals(BACKGROUND_HEIGHT, this._button.height);
		Assert.equals(BACKGROUND_MIN_WIDTH, this._button.minWidth);
		Assert.equals(BACKGROUND_MIN_HEIGHT, this._button.minHeight);
		Assert.equals(BACKGROUND_MAX_WIDTH, this._button.maxWidth);
		Assert.equals(BACKGROUND_MAX_HEIGHT, this._button.maxHeight);
	}
}
