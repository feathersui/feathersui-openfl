/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.events.Event;
import feathers.controls.LayoutGroup;
import feathers.events.StyleProviderEvent;
import utest.Assert;
import utest.Test;

@:keep
class FunctionStyleProviderTest extends Test {
	private var _control:LayoutGroup;
	private var _styleProvider:FunctionStyleProvider;
	private var _appliedStyles:Bool;

	public function new() {
		super();
	}

	public function setup():Void {
		this._appliedStyles = false;
		this._styleProvider = new FunctionStyleProvider(setExtraStyles);
		this._control = new LayoutGroup();
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		this._styleProvider = null;
		this._appliedStyles = false;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function setExtraStyles(target:LayoutGroup):Void {
		this._appliedStyles = true;
	}

	public function testCallback():Void {
		this._styleProvider.applyStyles(this._control);
		Assert.isTrue(this._appliedStyles, "Must call callback function when applying styles");
	}

	public function testNoErrorWithNullFunction():Void {
		this._styleProvider.callback = null;
		this._styleProvider.applyStyles(this._control);
		Assert.isFalse(this._appliedStyles, "Must not apply style provider when callback function is null");
	}

	public function testStyleProviderDispatchesChangeEventAfterChangeCallback():Void {
		var changed = false;
		this._styleProvider.addEventListener(StyleProviderEvent.STYLES_CHANGE, function(event:StyleProviderEvent):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._styleProvider.callback = function(target:LayoutGroup):Void {};
		Assert.isTrue(changed, "FunctionStyleProvider must dispatch StyleProviderEvent.STYLES_CHANGE after changing callback");
	}
}
