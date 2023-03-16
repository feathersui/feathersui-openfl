/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.display.Sprite;
import utest.Assert;
import utest.Test;

@:keep
class ExclusivePointerTest extends Test {
	private var _target:Sprite;
	private var _exclusivePointer:ExclusivePointer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._target = new Sprite();
		this._target.graphics.beginFill(0xff00ff);
		this._target.graphics.drawRect(0.0, 0.0, 200.0, 150.0);
		this._target.graphics.endFill();
		Lib.current.addChild(this._target);
		this._exclusivePointer = ExclusivePointer.forStage(Lib.current.stage);
	}

	public function teardown():Void {
		if (this._target.parent != null) {
			this._target.parent.removeChild(this._target);
		}
		this._target = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		this._exclusivePointer.removeAllClaims();
		this._exclusivePointer = null;
	}

	public function testClaimMouse():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimMouse(this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.equals(this._target, this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveMouseClaim():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimMouse(this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.equals(this._target, this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		this._exclusivePointer.removeMouseClaim();

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testClaimTouch():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimTouch(1, this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveTouchClaim():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimTouch(1, this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(1));

		this._exclusivePointer.removeTouchClaim(1);

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveTouchClaim2():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimTouch(0, this._target));
		Assert.isTrue(this._exclusivePointer.claimTouch(1, this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(0));
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(1));

		this._exclusivePointer.removeTouchClaim(1);

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		this._exclusivePointer.removeTouchClaim(0);

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveAllClaims():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimMouse(this._target));
		Assert.isTrue(this._exclusivePointer.claimTouch(1, this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.equals(this._target, this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(1));

		this._exclusivePointer.removeAllClaims();

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveMouseClaimAutomaticallyOnMouseUp():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimMouse(this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.equals(this._target, this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Lib.current.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}

	public function testRemoveTouchClaimAutomaticallyOnTouchEnd():Void {
		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));

		Assert.isTrue(this._exclusivePointer.claimTouch(1, this._target));

		Assert.isTrue(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.equals(this._target, this._exclusivePointer.getTouchClaim(1));

		Lib.current.stage.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_END, true, false, 1));

		Assert.isFalse(this._exclusivePointer.hasClaim());
		Assert.isNull(this._exclusivePointer.getMouseClaim());
		Assert.isNull(this._exclusivePointer.getTouchClaim(0));
		Assert.isNull(this._exclusivePointer.getTouchClaim(1));
	}
}
