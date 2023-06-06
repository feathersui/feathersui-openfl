/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.display.Shape;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.TextInput)
class TextInputTest extends Test {
	private var _input:TextInput;

	public function new() {
		super();
	}

	public function setup():Void {
		this._input = new TextInput();
		Lib.current.addChild(this._input);
	}

	public function teardown():Void {
		if (this._input.parent != null) {
			this._input.parent.removeChild(this._input);
		}
		this._input = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._input.validateNow();
		this._input.dispose();
		this._input.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetTextProgramatically():Void {
		this._input.validateNow();
		var changed = false;
		this._input.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._input.text = "Hello";
		Assert.isTrue(changed);
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin2;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._input.backgroundSkin = skin;
		this._input.validateNow();
		Assert.equals(this._input, skin.parent);
		this._input.backgroundSkin = null;
		this._input.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.DISABLED, skin2);
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.enabled = false;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}

	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.ERROR, skin2);
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.changeState(ERROR);
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}

	public function testErrorStringCalloutOpenAndCloseOnFocusChange():Void {
		Assert.isFalse(this._input.errorStringCalloutOpen);
		this._input.errorString = "Something is wrong";
		this._input.validateNow();
		Assert.isFalse(this._input.errorStringCalloutOpen);
		Lib.current.stage.focus = this._input;
		this._input.validateNow();
		Assert.isTrue(this._input.errorStringCalloutOpen);
		Lib.current.stage.focus = Lib.current.stage;
		this._input.validateNow();
		Assert.isFalse(this._input.errorStringCalloutOpen);
	}
}
