/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.Button;
import feathers.core.PopUpManager;
import utest.Assert;
import utest.Test;

@:keep
class DefaultPopUpManagerFocusManagerTest extends Test {
	private var _focusObject1:Button;
	private var _focusObject2:Button;
	private var _focusObject3:Button;

	public function new() {
		super();
	}

	public function setup():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root);
		PopUpManager.forStage(TestMain.openfl_root.stage).focusManager = focusManager;
		this._focusObject1 = new Button();
		TestMain.openfl_root.addChild(this._focusObject1);
		this._focusObject2 = new Button();
		this._focusObject3 = new Button();
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
		if (this._focusObject3.parent != null) {
			this._focusObject3.parent.removeChild(this._focusObject3);
		}
		this._focusObject3 = null;

		if (FocusManager.hasRoot(TestMain.openfl_root)) {
			FocusManager.removeRoot(TestMain.openfl_root);
		}
		PopUpManager.dispose();

		Assert.isFalse(FocusManager.hasRoot(TestMain.openfl_root), "Test cleanup failed to clean up focus manager root");

		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testAddFocusableChildAsNonModalPopUp():Void {
		PopUpManager.addPopUp(this._focusObject2, TestMain.openfl_root, false, false);
		Assert.notNull(this._focusObject1.focusManager, "Focus manager should not be null");
		Assert.notNull(this._focusObject2.focusManager, "Focus manager should not be null");
		Assert.equals(this._focusObject1.focusManager, this._focusObject2.focusManager, "Focus manager should be equal when adding non-modal pop-up");
	}

	public function testAddFocusableChildAsModalPopUp():Void {
		PopUpManager.addPopUp(this._focusObject2, TestMain.openfl_root, true, false);
		Assert.notNull(this._focusObject1.focusManager, "Focus manager should not be null");
		Assert.notNull(this._focusObject2.focusManager, "Focus manager should not be null");
		Assert.notEquals(this._focusObject1.focusManager, this._focusObject2.focusManager, "Focus manager should not be equal when adding modal pop-up");
	}

	public function testAddFocusableChildAsNonModalPopUpAfterModalPopUp():Void {
		PopUpManager.addPopUp(this._focusObject2, TestMain.openfl_root, true, false);
		PopUpManager.addPopUp(this._focusObject3, TestMain.openfl_root, false, false);
		Assert.notNull(this._focusObject1.focusManager, "Focus manager should not be null");
		Assert.notNull(this._focusObject2.focusManager, "Focus manager should not be null");
		Assert.notNull(this._focusObject3.focusManager, "Focus manager should not be null");
		Assert.notEquals(this._focusObject1.focusManager, this._focusObject2.focusManager, "Focus manager should not be equal when adding modal pop-up");
		Assert.equals(this._focusObject2.focusManager, this._focusObject3.focusManager,
			"Focus manager should be equal when adding non-modal pop-up after modal pop-up");
	}
}
