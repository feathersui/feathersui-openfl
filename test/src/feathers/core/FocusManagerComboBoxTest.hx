/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.events.FocusEvent;
import openfl.text.TextField;
import feathers.controls.ComboBox;
import utest.Assert;
import utest.Test;

@:keep
class FocusManagerComboBoxTest extends Test {
	private var _comboBox:ComboBox;

	public function new() {
		super();
	}

	public function setup():Void {
		this._comboBox = new ComboBox();
		TestMain.openfl_root.addChild(this._comboBox);
	}

	public function teardown():Void {
		if (this._comboBox != null) {
			if (this._comboBox.parent != null) {
				this._comboBox.parent.removeChild(this._comboBox);
			}
			this._comboBox = null;
		}
		FocusManager.dispose();
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testSetFocusManagerFocus():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._comboBox.validateNow();
		var focusInCount = 0;
		this._comboBox.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		focusManager.focus = this._comboBox;
		Assert.isTrue((TestMain.openfl_root.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._comboBox.validateNow();
		var focusInCount = 0;
		this._comboBox.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		TestMain.openfl_root.stage.focus = this._comboBox;
		Assert.isTrue((TestMain.openfl_root.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithoutFocusManager():Void {
		this._comboBox.validateNow();
		var focusInCount = 0;
		this._comboBox.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		TestMain.openfl_root.stage.focus = this._comboBox;
		Assert.isTrue((TestMain.openfl_root.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}
}
