/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.LayoutGroup;
import openfl.Lib;
import openfl.errors.Error;
import utest.Assert;
import utest.Test;

@:keep
class InvalidationTest extends Test {
	private var _control:LayoutGroup;
	private var _control2:SetInvalidDuringValidation;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new LayoutGroup();
		Lib.current.addChild(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		if (this._control2 != null && this._control2.parent != null) {
			this._control2.parent.removeChild(this._control2);
		}
		this._control2 = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNotInvalidAfterConstructor() {
		var control = new LayoutGroup();
		Assert.isFalse(control.isInvalid(), "Feathers component must not be invalid before initialize");
		Assert.isFalse(control.isInvalid(InvalidationFlag.DATA), "Feathers component must not be invalid before initialize");
	}

	public function testIsInvalidAfterForcedInitialize() {
		var control = new LayoutGroup();
		control.initializeNow();
		Assert.isTrue(control.isInvalid(), "Feathers component must be invalid after forced initialize");
		Assert.isTrue(control.isInvalid(InvalidationFlag.DATA), "Feathers component must be invalid with all flags after forced initialize");
	}

	public function testIsInvalidAfterAutomaticInitialize() {
		Assert.isTrue(this._control.isInvalid(), "Feathers component must be invalid after automatic initialize");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.DATA), "Feathers component must be invalid with all flags after automatic initialize");
	}

	public function testNotInvalidAfterValidate() {
		this._control.validateNow();
		Assert.isFalse(this._control.isInvalid(), "Feathers component must not be invalid after validate");
		Assert.isFalse(this._control.isInvalid(InvalidationFlag.DATA), "Feathers component must not be invalid with flags after validate");
	}

	public function testIsInvalidAfterSetInvalid() {
		this._control.validateNow();
		this._control.setInvalid();
		Assert.isTrue(this._control.isInvalid(), "Feathers component must be invalid after setInvalid() with no flags");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.DATA), "Feathers component must be invalid with any flag after setInvalid() with no flags");
	}

	public function testIsInvalidAfterSetInvalidWithFlag() {
		this._control.validateNow();
		this._control.setInvalid(InvalidationFlag.DATA);
		Assert.isTrue(this._control.isInvalid(), "Feathers component must be invalid after setInvalid() with a flag");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.DATA), "Feathers component must be invalid with flag after setInvalid() with the same flag");
		Assert.isFalse(this._control.isInvalid(InvalidationFlag.STYLES),
			"Feathers component must not be invalid with flag after setInvalid() with different flag");
	}

	public function testIsInvalidAfterSetInvalidWithMultipleFlags() {
		this._control.validateNow();
		this._control.setInvalid(InvalidationFlag.DATA);
		this._control.setInvalid(InvalidationFlag.STATE);
		Assert.isTrue(this._control.isInvalid(), "Feathers component must be invalid after setInvalid() with a flag");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.DATA), "Feathers component must be invalid with flag after setInvalid() with the same flag");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.STATE), "Feathers component must be invalid with flag after setInvalid() with the same flag");
		Assert.isFalse(this._control.isInvalid(InvalidationFlag.STYLES),
			"Feathers component must not be invalid with flag after setInvalid() with different flag");
	}

	public function testIsInvalidAfterSetInvalidWithCustomFlag() {
		this._control.validateNow();
		this._control.setInvalid(InvalidationFlag.CUSTOM("one"));
		Assert.isTrue(this._control.isInvalid(), "Feathers component must be invalid after setInvalid() with a flag");
		Assert.isTrue(this._control.isInvalid(InvalidationFlag.CUSTOM("one")),
			"Feathers component must be invalid with flag after setInvalid() with the same flag");
		Assert.isFalse(this._control.isInvalid(InvalidationFlag.CUSTOM("two")),
			"Feathers component must not be invalid with flag after setInvalid() with different flag");
		Assert.isFalse(this._control.isInvalid(InvalidationFlag.STYLES),
			"Feathers component must not be invalid with flag after setInvalid() with different flag");
	}

	#if !feathersui_strict_set_invalid
	public function testInfiniteInvalidateDuringValidation() {
		this._control2 = new SetInvalidDuringValidation();
		Lib.current.addChild(this._control2);

		Assert.raises(() -> {
			ValidationQueue.forStage(this._control2.stage).validateNow();
		}, Error);
	}

	public function testSingleInvalidateDuringValidation() {
		this._control2 = new SetInvalidDuringValidation();
		this._control2.numTimes = 1;
		Lib.current.addChild(this._control2);
		this._control2.validateNow();
		Assert.isTrue(this._control2.isInvalid());
		this._control2.validateNow();
		Assert.isFalse(this._control2.isInvalid());
	}
	#end
}

class SetInvalidDuringValidation extends LayoutGroup {
	public var numTimes = 0;

	private var actualNumTimes = 0;

	public var flag:InvalidationFlag = null;

	override private function update():Void {
		super.update();
		if (numTimes == 0 || actualNumTimes < numTimes) {
			this.setInvalid(flag);
		}
		actualNumTimes++;
	}
}

class SingleInvalidationControl extends LayoutGroup {
	override private function update():Void {
		super.update();
		this.setInvalid();
	}
}
