/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
import massive.munit.Assert;

@:keep
class BasicButtonMeasurementTest {
	private static final SHAPE_WIDTH = 10.0;
	private static final SHAPE_HEIGHT = 12.0;
	private static final BACKGROUND_WIDTH = 30.0;
	private static final BACKGROUND_HEIGHT = 32.0;
	private static final BACKGROUND_MIN_WIDTH = 20.0;
	private static final BACKGROUND_MIN_HEIGHT = 18.0;
	private static final BACKGROUND_MAX_WIDTH = 50.0;
	private static final BACKGROUND_MAX_HEIGHT = 45.0;

	private var _button:BasicButton;

	@Before
	public function prepare():Void {
		this._button = new BasicButton();
		TestMain.openfl_root.addChild(this._button);
	}

	@After
	public function cleanup():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
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

	@Test
	public function testMeasurementsWithNoBackgroundSkin():Void {
		this._button.validateNow();

		Assert.areEqual(0.0, this._button.width);
		Assert.areEqual(0.0, this._button.height);
		Assert.areEqual(0.0, this._button.minWidth);
		Assert.areEqual(0.0, this._button.minHeight);
		Assert.areEqual(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.areEqual(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	@Test
	public function testMeasurementsWithShapeBackgroundSkin():Void {
		this.addShapeBackground();
		this._button.validateNow();

		Assert.areEqual(SHAPE_WIDTH, this._button.width);
		Assert.areEqual(SHAPE_HEIGHT, this._button.height);
		Assert.areEqual(SHAPE_WIDTH, this._button.minWidth);
		Assert.areEqual(SHAPE_HEIGHT, this._button.minHeight);
		Assert.areEqual(SHAPE_WIDTH, this._button.maxWidth);
		Assert.areEqual(SHAPE_HEIGHT, this._button.maxHeight);
	}

	@Test
	public function testMeasurementsWithRectangleSkinBackgroundSkin():Void {
		this.addRectangleSkinBackground();
		this._button.validateNow();

		Assert.areEqual(BACKGROUND_WIDTH, this._button.width);
		Assert.areEqual(BACKGROUND_HEIGHT, this._button.height);
		Assert.areEqual(BACKGROUND_MIN_WIDTH, this._button.minWidth);
		Assert.areEqual(BACKGROUND_MIN_HEIGHT, this._button.minHeight);
		Assert.areEqual(BACKGROUND_MAX_WIDTH, this._button.maxWidth);
		Assert.areEqual(BACKGROUND_MAX_HEIGHT, this._button.maxHeight);
	}
}
