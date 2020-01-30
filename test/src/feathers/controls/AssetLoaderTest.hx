/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.StageScaleMode;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import massive.munit.util.Timer;
import massive.munit.async.AsyncFactory;
import openfl.events.Event;
import massive.munit.Assert;

@:keep
class AssetLoaderTest {
	private static final BLUE100x50 = "blue100x50.png";
	private static final RED200x300 = "red200x300.png";

	private var _loader:AssetLoader;

	@Before
	public function prepare():Void {
		this._loader = new AssetLoader();
		TestMain.openfl_root.addChild(this._loader);
	}

	@After
	public function cleanup():Void {
		if (this._loader.parent != null) {
			this._loader.parent.removeChild(this._loader);
		}
		this._loader = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	#if (js || flash)
	@AsyncTest
	public function testCompleteEvent(factory:AsyncFactory):Void {
		var complete = false;
		var ioError = false;
		var securityError = false;
		this._loader.addEventListener(Event.COMPLETE, function(event:Event):Void {
			complete = true;
		});
		this._loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):Void {
			ioError = true;
		});
		this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:Event):Void {
			securityError = true;
		});
		this._loader.source = BLUE100x50;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			Assert.isTrue(complete);
			Assert.isFalse(ioError);
			Assert.isFalse(securityError);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testIOErrorEvent(factory:AsyncFactory):Void {
		var complete = false;
		var ioError = false;
		var securityError = false;
		this._loader.addEventListener(Event.COMPLETE, function(event:Event):Void {
			complete = true;
		});
		this._loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):Void {
			ioError = true;
		});
		this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:Event):Void {
			securityError = true;
		});
		this._loader.source = "fake.png";
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			Assert.isFalse(complete);
			Assert.isTrue(ioError);
			Assert.isFalse(securityError);
		}, 3200);
		// chrome needs a really long delay, for some reason!
		Timer.delay(handler, 3000);
	}

	@AsyncTest
	public function testResize(factory:AsyncFactory):Void {
		this._loader.source = BLUE100x50;
		this._loader.validateNow();
		var resize = false;
		this._loader.addEventListener(Event.RESIZE, function(event:Event):Void {
			resize = true;
		});
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.isTrue(resize);
			Assert.areEqual(100, this._loader.width);
			Assert.areEqual(50, this._loader.height);
			Assert.areEqual(100, this._loader.minWidth);
			Assert.areEqual(50, this._loader.minHeight);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testResizeWithNewSource(factory:AsyncFactory):Void {
		var resize = false;
		this._loader.addEventListener(Event.COMPLETE, function(event:Event):Void {
			if (this._loader.source == BLUE100x50) {
				this._loader.source = RED200x300;
				this._loader.validateNow();
				resize = false;
				this._loader.addEventListener(Event.RESIZE, function(event:Event):Void {
					resize = true;
				});
			}
		});
		this._loader.source = BLUE100x50;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.isTrue(resize);
			Assert.areEqual(200, this._loader.width);
			Assert.areEqual(300, this._loader.height);
			Assert.areEqual(200, this._loader.minWidth);
			Assert.areEqual(300, this._loader.minHeight);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testAutoSizeWidthWithScaleModeNoScale(factory:AsyncFactory):Void {
		this._loader.source = BLUE100x50;
		this._loader.height = 200;
		this._loader.scaleMode = StageScaleMode.NO_SCALE;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.areEqual(100, this._loader.width);
			Assert.areEqual(100, this._loader.minWidth);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testAutoSizeHeightWithScaleModeNoScale(factory:AsyncFactory):Void {
		this._loader.source = BLUE100x50;
		this._loader.width = 200;
		this._loader.scaleMode = StageScaleMode.NO_SCALE;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.areEqual(50, this._loader.height);
			Assert.areEqual(50, this._loader.minHeight);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testAutoSizeWidthWithScaleModeShowAll(factory:AsyncFactory):Void {
		this._loader.source = BLUE100x50;
		this._loader.height = 200;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.areEqual(400, this._loader.width);
			Assert.areEqual(400, this._loader.minWidth);
		}, 1000);
		Timer.delay(handler, 800);
	}

	@AsyncTest
	public function testAutoSizeHeightWithScaleModeShowAll(factory:AsyncFactory):Void {
		this._loader.source = BLUE100x50;
		this._loader.width = 200;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.areEqual(100, this._loader.height);
			Assert.areEqual(100, this._loader.minHeight);
		}, 1000);
		Timer.delay(handler, 800);
	}

	// BowlerHatLLC/feathersui-starling#1541

	@AsyncTest
	public function testEpxlicitMaxSizeWithLargerMinSize(factory:AsyncFactory):Void {
		var maxWidth = 50.0;
		var maxHeight = 75.0;
		this._loader.source = BLUE100x50;
		this._loader.maxWidth = maxWidth;
		this._loader.maxHeight = maxHeight;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		var handler = factory.createHandler(this, function():Void {
			this._loader.validateNow();
			Assert.areEqual(maxWidth, this._loader.width);
			Assert.areEqual(maxHeight, this._loader.height);
		}, 1000);
		Timer.delay(handler, 800);
	}
	#end
}
