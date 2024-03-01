/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.ToggleButton)
class ToggleButtonTest extends Test {
	private var _button:ToggleButton;

	public function new() {
		super();
	}

	public function setup():Void {
		this._button = new ToggleButton();
		Lib.current.addChild(this._button);
	}

	public function teardown():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._button.validateNow();
		this._button.dispose();
		this._button.dispose();
		Assert.pass();
	}

	public function testRemoveIconAfterSetToNewValue():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.validateNow();
		Assert.equals(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon2;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.equals(this._button, icon2.parent);
	}

	public function testRemoveIconAfterSetToNull():Void {
		var icon = new Shape();
		Assert.isNull(icon.parent);
		this._button.icon = icon;
		this._button.validateNow();
		Assert.equals(this._button, icon.parent);
		this._button.icon = null;
		this._button.validateNow();
		Assert.isNull(icon.parent);
	}

	public function testRemoveIconAfterDisable():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.setIconForState(ToggleButtonState.DISABLED(false), icon2);
		this._button.validateNow();
		Assert.equals(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.enabled = false;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.equals(this._button, icon2.parent);
	}

	public function testRemoveIconAfterSelect():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.selectedIcon = icon2;
		this._button.validateNow();
		Assert.equals(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.selected = true;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.equals(this._button, icon2.parent);
	}

	public function testRemoveIconAfterChangeState():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.setIconForState(ToggleButtonState.DOWN(false), icon2);
		this._button.validateNow();
		Assert.equals(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.changeState(ToggleButtonState.DOWN(false));
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.equals(this._button, icon2.parent);
	}

	public function testResizeAfterIconResize():Void {
		var icon = new LayoutGroup();
		icon.width = 100.0;
		icon.height = 100.0;
		this._button.icon = icon;
		this._button.validateNow();
		var originalWidth = this._button.width;
		var originalHeight = this._button.height;
		icon.width = 200.0;
		icon.height = 150.0;
		this._button.validateNow();
		Assert.notEquals(originalWidth, this._button.width);
		Assert.notEquals(originalHeight, this._button.height);
	}
}
