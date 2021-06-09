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

	public function teardown():Void {
		if (this._focusObject1 != null) {
			if (this._focusObject1.parent != null) {
				this._focusObject1.parent.removeChild(this._focusObject1);
			}
			this._focusObject1 = null;
		}
		if (this._focusObject2 != null) {
			if (this._focusObject2.parent != null) {
				this._focusObject2.parent.removeChild(this._focusObject2);
			}
			this._focusObject2 = null;
		}
		FocusManager.dispose();
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	private function createFocusObject1():Void {
		this._focusObject1 = new Button();
		TestMain.openfl_root.addChild(this._focusObject1);
	}

	private function createFocusObject2():Void {
		this._focusObject2 = new Button();
		TestMain.openfl_root.addChild(this._focusObject2);
	}

	public function testHasRoot():Void {
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
		FocusManager.addRoot(TestMain.openfl_root.stage);
		Assert.isTrue(FocusManager.hasRoot(TestMain.openfl_root.stage));
	}

	public function testDispose():Void {
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		Assert.isTrue(FocusManager.hasRoot(TestMain.openfl_root.stage));
		focusManager.dispose();
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
	}

	public function testRemoveRoot():Void {
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
		FocusManager.addRoot(TestMain.openfl_root.stage);
		Assert.isTrue(FocusManager.hasRoot(TestMain.openfl_root.stage));
		FocusManager.removeRoot(TestMain.openfl_root.stage);
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
	}

	public function testDisposeAll():Void {
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
		FocusManager.addRoot(TestMain.openfl_root.stage);
		Assert.isTrue(FocusManager.hasRoot(TestMain.openfl_root.stage));
		FocusManager.dispose();
		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root.stage));
	}

	public function testFocusManagerProperty():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		Assert.notNull(focusManager, "Focus manager should not be null");
		createFocusObject1();
		createFocusObject2();
		Assert.equals(focusManager, this._focusObject1.focusManager, "Focus manager should be equal");
		Assert.equals(focusManager, this._focusObject2.focusManager, "Focus manager should be equal");
	}

	public function testRemoveFocusManagerOnRemoveChild():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		createFocusObject1();
		TestMain.openfl_root.removeChild(this._focusObject1);
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null after removing from stage");
	}

	public function testRemoveFocusManagerOnRemoveRoot():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		createFocusObject1();
		createFocusObject2();
		focusManager.dispose();
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null after disposing");
		Assert.isNull(this._focusObject2.focusManager, "Focus manager should be null after disposing");
	}

	public function testFocusPropertyInFocusInEventListener():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this.createFocusObject1();
		var focusIsCorrectInListener = false;
		Assert.isTrue(this._focusObject1.focusManager.focus != this._focusObject1, "The focus property of the FocusManager is incorrect at start of test");
		this._focusObject1.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):Void {
			focusIsCorrectInListener = this._focusObject1.focusManager.focus == this._focusObject1;
		});
		this._focusObject1.focusManager.focus = this._focusObject1;
		Assert.isTrue(focusIsCorrectInListener, "The focus property of the FocusManager is not updated before calling listener for FocusEvent.FOCUS_IN event");
	}

	public function testFocusPropertyInFocusOutEventListener():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this.createFocusObject1();
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
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this.createFocusObject1();
		this.createFocusObject2();
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject1.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject2, false, Keyboard.TAB));
		Assert.equals(this._focusObject2.focusManager.focus, this._focusObject2, "The FocusManager did not change focus when pressing Keyboard.TAB");
	}

	public function testFocusChangeOnShiftPlusTabKey():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this.createFocusObject1();
		this.createFocusObject2();
		this._focusObject1.focusManager.focus = this._focusObject2;
		this._focusObject2.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject1, true, Keyboard.TAB));
		Assert.equals(this._focusObject1.focusManager.focus, this._focusObject1,
			"The FocusManager did not change focus when pressing Keyboard.TAB with shiftKey");
	}
}
