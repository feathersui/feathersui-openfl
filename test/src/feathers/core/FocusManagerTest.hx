/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.Button;
import openfl.Lib;
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
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, Lib.current.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	private function createFocusObject1():Void {
		this._focusObject1 = new Button();
		Lib.current.addChild(this._focusObject1);
	}

	private function createFocusObject2():Void {
		this._focusObject2 = new Button();
		Lib.current.addChild(this._focusObject2);
	}

	public function testHasRoot():Void {
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
		FocusManager.addRoot(Lib.current.stage);
		Assert.isTrue(FocusManager.hasRoot(Lib.current.stage));
	}

	public function testDispose():Void {
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		Assert.isTrue(FocusManager.hasRoot(Lib.current.stage));
		focusManager.dispose();
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
	}

	public function testRemoveRoot():Void {
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
		FocusManager.addRoot(Lib.current.stage);
		Assert.isTrue(FocusManager.hasRoot(Lib.current.stage));
		FocusManager.removeRoot(Lib.current.stage);
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
	}

	public function testDisposeAll():Void {
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
		FocusManager.addRoot(Lib.current.stage);
		Assert.isTrue(FocusManager.hasRoot(Lib.current.stage));
		FocusManager.dispose();
		Assert.isFalse(FocusManager.hasRoot(Lib.current.stage));
	}

	public function testFocusManagerProperty():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		Assert.notNull(focusManager, "Focus manager should not be null");
		createFocusObject1();
		createFocusObject2();
		Assert.equals(focusManager, this._focusObject1.focusManager, "Focus manager should be equal");
		Assert.equals(focusManager, this._focusObject2.focusManager, "Focus manager should be equal");
	}

	public function testRemoveFocusManagerOnRemoveChild():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		createFocusObject1();
		Lib.current.removeChild(this._focusObject1);
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null after removing from stage");
	}

	public function testRemoveFocusManagerOnRemoveRoot():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		createFocusObject1();
		createFocusObject2();
		focusManager.dispose();
		Assert.isNull(this._focusObject1.focusManager, "Focus manager should be null after disposing");
		Assert.isNull(this._focusObject2.focusManager, "Focus manager should be null after disposing");
	}

	public function testFocusPropertyInFocusInEventListener():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		var focusManagerFocusIsCorrectInListener = false;
		var stageFocusIsCorrectInListener = false;
		Assert.isTrue(this._focusObject1.focusManager.focus != this._focusObject1, "The focus property of the FocusManager is incorrect at start of test");
		this._focusObject1.addEventListener(FocusEvent.FOCUS_IN, function(event:FocusEvent):Void {
			focusManagerFocusIsCorrectInListener = this._focusObject1.focusManager.focus == this._focusObject1;
			stageFocusIsCorrectInListener = this._focusObject1.stage.focus == this._focusObject1;
		});
		this._focusObject1.focusManager.focus = this._focusObject1;
		Assert.isTrue(focusManagerFocusIsCorrectInListener,
			"The focus property of the FocusManager is not updated before calling listener for FocusEvent.FOCUS_IN event");
		Assert.isTrue(stageFocusIsCorrectInListener, "The focus property of the Stage is not updated before calling listener for FocusEvent.FOCUS_IN event");
	}

	public function testFocusPropertyInFocusOutEventListener():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		var focusManagerFocusIsCorrectInListener = false;
		var stageFocusIsCorrectInListener = false;
		this._focusObject1.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):Void {
			focusManagerFocusIsCorrectInListener = this._focusObject1.focusManager.focus == this._focusObject1;
			stageFocusIsCorrectInListener = this._focusObject1.stage.focus == this._focusObject1;
		});
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject1.focusManager.focus = null;
		Assert.isFalse(focusManagerFocusIsCorrectInListener,
			"The focus property of the FocusManager is not updated before calling listener for FocusEvent.FOCUS_OUT event");
		Assert.isFalse(stageFocusIsCorrectInListener, "The focus property of the Stage is not updated before calling listener for FocusEvent.FOCUS_OUT event");
	}

	public function testFocusChangeOnTabKey():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		this.createFocusObject2();
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject1.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject2, false, Keyboard.TAB));
		Assert.equals(this._focusObject2.focusManager.focus, this._focusObject2, "The FocusManager did not change focus when pressing Keyboard.TAB");
		Assert.equals(this._focusObject2.stage.focus, this._focusObject2, "The FocusManager did not change stage focus when pressing Keyboard.TAB");
	}

	public function testFocusChangeOnShiftPlusTabKey():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		this.createFocusObject2();
		this._focusObject1.focusManager.focus = this._focusObject2;
		this._focusObject2.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, this._focusObject1, true, Keyboard.TAB));
		Assert.equals(this._focusObject1.focusManager.focus, this._focusObject1,
			"The FocusManager did not change focus when pressing Keyboard.TAB with shiftKey");
		Assert.equals(this._focusObject1.stage.focus, this._focusObject1,
			"The FocusManager did not change stage focus when pressing Keyboard.TAB with shiftKey");
	}

	public function checkFocusAfterAddModalPopUp():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject2 = new Button();
		PopUpManager.addPopUp(this._focusObject2, Lib.current, true);
		Assert.notEquals(focusManager.focus, this._focusObject1, "The FocusManager failed to change focus when adding a modal pop-up");
		Assert.notEquals(Lib.current.stage.focus, this._focusObject1, "The FocusManager failed to change focus when adding a modal pop-up");
	}

	public function checkFocusAfterAddNonModalPopUp():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this.createFocusObject1();
		this._focusObject1.focusManager.focus = this._focusObject1;
		this._focusObject2 = new Button();
		PopUpManager.addPopUp(this._focusObject2, Lib.current, false);
		Assert.equals(this._focusObject1.focusManager.focus, this._focusObject1, "The FocusManager incorrectly changed focus when adding a non-modal pop-up");
		Assert.equals(Lib.current.stage.focus, this._focusObject1, "The FocusManager incorrectly changed focus when adding a non-modal pop-up");
	}
}
