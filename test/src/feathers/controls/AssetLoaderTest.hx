/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import haxe.Timer;
import openfl.Lib;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import utest.Assert;
import utest.Async;
import utest.Test;

#if hl
@:keep
class AssetLoaderTest extends Test {}
#else
@:keep
class AssetLoaderTest extends Test {
	private static final BLUE100x50 = "assets/fixtures/blue100x50.png";
	private static final RED200x300 = "assets/fixtures/red200x300.png";

	private var _loader:AssetLoader;

	public function new() {
		super();
	}

	public function setup():Void {
		this._loader = new AssetLoader();
		Lib.current.addChild(this._loader);
	}

	public function teardown():Void {
		if (this._loader.parent != null) {
			this._loader.parent.removeChild(this._loader);
		}
		this._loader = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@:timeout(1000)
	public function testCompleteEvent(async:Async):Void {
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
		Timer.delay(() -> {
			Assert.isTrue(complete);
			Assert.isFalse(ioError);
			Assert.isFalse(securityError);
			async.done();
		}, 800);
	}

	@:timeout(3200)
	public function testIOErrorEvent(async:Async):Void {
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
		// chrome needs a really long delay, for some reason!
		Timer.delay(() -> {
			Assert.isFalse(complete);
			Assert.isTrue(ioError);
			Assert.isFalse(securityError);
			async.done();
		}, 3000);
	}

	@:timeout(1000)
	public function testResize(async:Async):Void {
		this._loader.source = BLUE100x50;
		this._loader.validateNow();
		var resize = false;
		this._loader.addEventListener(Event.RESIZE, function(event:Event):Void {
			resize = true;
		});
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.isTrue(resize);
			Assert.equals(100, this._loader.width);
			Assert.equals(50, this._loader.height);
			Assert.equals(100, this._loader.minWidth);
			Assert.equals(50, this._loader.minHeight);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	public function testResizeWithNewSource(async:Async):Void {
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
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.isTrue(resize);
			Assert.equals(200, this._loader.width);
			Assert.equals(300, this._loader.height);
			Assert.equals(200, this._loader.minWidth);
			Assert.equals(300, this._loader.minHeight);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	public function testAutoSizeWidthWithScaleModeNoScale(async:Async):Void {
		this._loader.source = BLUE100x50;
		this._loader.height = 200;
		this._loader.scaleMode = StageScaleMode.NO_SCALE;
		this._loader.validateNow();
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.equals(100, this._loader.width);
			Assert.equals(100, this._loader.minWidth);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	public function testAutoSizeHeightWithScaleModeNoScale(async:Async):Void {
		this._loader.source = BLUE100x50;
		this._loader.width = 200;
		this._loader.scaleMode = StageScaleMode.NO_SCALE;
		this._loader.validateNow();
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.equals(50, this._loader.height);
			Assert.equals(50, this._loader.minHeight);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	public function testAutoSizeWidthWithScaleModeShowAll(async:Async):Void {
		this._loader.source = BLUE100x50;
		this._loader.height = 200;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.equals(400, this._loader.width);
			Assert.equals(400, this._loader.minWidth);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	// feathersui/feathersui-openfl#131
	public function testExplicitMaxWidthAndExplicitMaxHeightMaintainsAspectRatio1(async:Async):Void {
		var maxWidth = 250.0;
		var maxHeight = 150.0;
		this._loader.source = RED200x300;
		this._loader.maxWidth = maxWidth;
		this._loader.maxHeight = maxHeight;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.equals(100.0, this._loader.width);
			Assert.equals(maxHeight, this._loader.height);
			async.done();
		}, 800);
	}

	@:timeout(1000)
	// feathersui/feathersui-openfl#131
	public function testExplicitMaxWidthAndExplicitMaxHeightMaintainsAspectRatio2(async:Async):Void {
		var maxWidth = 50.0;
		var maxHeight = 75.0;
		this._loader.source = BLUE100x50;
		this._loader.maxWidth = maxWidth;
		this._loader.maxHeight = maxHeight;
		this._loader.scaleMode = StageScaleMode.SHOW_ALL;
		this._loader.validateNow();
		Timer.delay(() -> {
			this._loader.validateNow();
			Assert.equals(maxWidth, this._loader.width);
			Assert.equals(25.0, this._loader.height);
			async.done();
		}, 800);
	}
}
#end
