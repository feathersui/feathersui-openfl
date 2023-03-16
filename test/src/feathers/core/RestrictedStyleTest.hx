/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.core.FeathersControl)
class RestrictedStyleTest extends Test {
	private var _control:CustomStyleControl;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new CustomStyleControl();
	}

	public function teardown():Void {
		this._control = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testStyleNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("style1"), "Style property must not be restricted after constructor.");
		Assert.isFalse(this._control.isStyleRestricted("style2"), "Style property must not be restricted after constructor.");
	}

	public function testStyleNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("style1"), "Style property must not be restricted after initialize.");
		Assert.isFalse(this._control.isStyleRestricted("style2"), "Style property must not be restricted after initialize.");
	}

	public function testStyleNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("style1"), "Style property must not be restricted after validate.");
		Assert.isFalse(this._control.isStyleRestricted("style2"), "Style property must not be restricted after validate.");
	}

	public function testRestrictedStyle():Void {
		this._control.style1 = "value";
		Assert.isTrue(this._control.isStyleRestricted("style1"), "Setting style property must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("style2"), "Setting style property must not restrict a different style.");
	}

	public function testRestrictedStyleSetToDefault():Void {
		this._control.style1 = null;
		Assert.isTrue(this._control.isStyleRestricted("style1"), "Setting style property must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("style2"), "Setting style property must not restrict a different style.");
	}

	public function testStyleWithStateNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.ONE), "Style with state must not be restricted after constructor.");
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.TWO), "Style with state must not be restricted after constructor.");
	}

	public function testStyleWithStateNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.ONE), "Style with state must not be restricted after initialize.");
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.TWO), "Style with state must not be restricted after initialize.");
	}

	public function testStyleWithStateNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.ONE), "Style with state must not be restricted after validate.");
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.TWO), "Style with state must not be restricted after validate.");
	}

	public function testRestrictedStyleWithState():Void {
		this._control.setStateStyle(CustomStyleEnum.ONE, "value");
		Assert.isTrue(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.ONE), "Calling style for state function must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("setStateStyle", CustomStyleEnum.TWO),
			"Calling style for state function must not restrict a different state.");
	}
}

private class CustomStyleControl extends FeathersControl {
	public function new() {
		super();
	}

	@:style
	public var style1:String = null;
	@:style
	public var style2:String = null;

	@style
	public function setStateStyle(state:CustomStyleEnum, value:String):Void {
		if (!this.setStyle("setStateStyle", state)) {
			return;
		}
	}
}

private enum CustomStyleEnum {
	ONE;
	TWO;
}
