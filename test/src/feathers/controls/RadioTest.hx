/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.ToggleGroup;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class RadioTest extends Test {
	private var _radio:Radio;

	public function new() {
		super();
	}

	public function setup():Void {
		this._radio = new Radio();
		Lib.current.addChild(this._radio);
	}

	public function teardown():Void {
		if (this._radio.parent != null) {
			this._radio.parent.removeChild(this._radio);
		}
		this._radio = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._radio.validateNow();
		this._radio.dispose();
		this._radio.dispose();
		Assert.pass();
	}

	public function testDefaultToggleGroup():Void {
		Assert.equals(Radio.defaultRadioGroup, this._radio.toggleGroup,
			"toggleGroup property must be equal to Radio.defaultRadioGroup if not yet added to another group.");
	}

	public function testToggleGroupPropertyAfterAddingExternally():Void {
		var group = new ToggleGroup();
		group.addItem(this._radio);
		Assert.equals(group, this._radio.toggleGroup, "toggleGroup property must be equal to ToggleGroup after adding to that group.");
	}

	public function testToggleGroupPropertyAfterRemovingExternally():Void {
		var group = new ToggleGroup();
		group.addItem(this._radio);
		group.removeItem(this._radio);
		Assert.equals(Radio.defaultRadioGroup, this._radio.toggleGroup,
			"toggleGroup property must be equal to Radio.defaultRadioGroup after removing a ToggleButton from another ToggleGroup.");
	}
}
