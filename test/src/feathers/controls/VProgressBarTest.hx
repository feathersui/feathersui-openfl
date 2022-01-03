/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class VProgressBarTest extends Test {
	private var _progress:VProgressBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._progress = new VProgressBar();
		TestMain.openfl_root.addChild(this._progress);
	}

	public function teardown():Void {
		if (this._progress.parent != null) {
			this._progress.parent.removeChild(this._progress);
		}
		this._progress = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testDispatchChangeEventOnSetValue():Void {
		this._progress.value = 0.5;
		var changed = false;
		this._progress.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(0.5, this._progress.value);
		Assert.isFalse(changed);
		this._progress.value = 1.0;
		Assert.isTrue(changed);
		Assert.equals(1.0, this._progress.value);
	}
}
