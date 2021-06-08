/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.Button;
import openfl.events.FocusEvent;
import openfl.ui.Keyboard;
import utest.Assert;
import utest.Test;

@:keep
class FocusManagerTest extends Test {
	private var _focusObject1:Button;
	private var _focusObject2:Button;

	public function new() {
		super();
	}

	public function setup():Void {
		FocusManager.addRoot(TestMain.openfl_root);
		this._focusObject1 = new Button();
		TestMain.openfl_root.addChild(this._focusObject1);
		this._focusObject2 = new Button();
		TestMain.openfl_root.addChild(this._focusObject2);
	}

	public function teardown():Void {
		if (this._focusObject1.parent != null) {
			this._focusObject1.parent.removeChild(this._focusObject1);
		}
		this._focusObject1 = null;
		if (this._focusObject2.parent != null) {
			this._focusObject2.parent.removeChild(this._focusObject2);
		}
		this._focusObject2 = null;

		if (FocusManager.hasRoot(TestMain.openfl_root)) {
			FocusManager.removeRoot(TestMain.openfl_root);
		}

		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root), "Test cleanup failed to clean up focus manager root");

		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testFocusManagerProperty():Void {
		Assert.notNull(this._focusObject1.focusManager, "Focus manager should not be null");
		Assert.notNull(this._focusObject2.focusManager, "Focus manager should not be null");
		Assert.equals(this._focusObject1.focusManager, this._focusObject2.focusManager, "Focus manager should be equal");
	}

	public function testRemoveFocusManagerOnRemoveChild():Void {
		TestMain.openfl_root.removeChild(this._focusObject1);
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null");
	}

	public function testRemoveFocusManagerOnRemoveRoot():Void {
		FocusManager.removeRoot(TestMain.openfl_root);
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null");
		Assert.isNull(this._focusObject2.focusManager, "Focus manager should be null");
	}

	public function testFocusPropertyInFocusInEventListener():Void {
		var focusIsCorrectInListener = false;
		Assert.isTrue(this._focusObject1.focusManager.focus != this._focusObject1, "The focus property of the FocusManager is incorrect at start of test");
		this._focusObject1.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):Void {
			focusIsCorrectInListener = this._focusObject1.focusManager.focus == this._focusObject1;
		});
		this._focusObject1.focusManager.focus = this._focusObject1;
		Assert.isTrue(focusIsCorrectInListener, "The focus property of the FocusManager is not updated before calling listener for FocusEvent.FOCUS_IN event");
	}

	public function testFocusPropertyInFocusOutEventListener():Void {
		var focusIsCorrectInListener = false;
		this._focusObject1.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):Void {
			focusIsCorrectInListener = this._focusObject1.focusManager.focus == null;
		});
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject1.focusManager.focus = null;
		Assert.isTrue(focusIsCorrectInListener,
			"The focus property of the FocusManager is not updated before calling listener for FocusEvent.FOCUS_OUT event");
	}

	public function testFocusChangeOnTabKey():Void {
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject1.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject2, false, Keyboard.TAB));
		Assert.equals(this._focusObject2.focusManager.focus, this._focusObject2, "The FocusManager did not change focus when pressing Keyboard.TAB");
	}

	public function testFocusChangeOnShiftPlusTabKey():Void {
		this._focusObject1.focusManager.focus = this._focusObject2;
		this._focusObject2.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject1, true, Keyboard.TAB));
		Assert.equals(this._focusObject1.focusManager.focus, this._focusObject1,
			"The FocusManager did not change focus when pressing Keyboard.TAB with shiftKey");
	}
}
