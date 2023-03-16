/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.TextInput;
import openfl.Lib;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import utest.Assert;
import utest.Test;

@:keep
class FocusManagerTextInputTest extends Test {
	private var _textInput:TextInput;

	public function new() {
		super();
	}

	public function setup():Void {
		this._textInput = new TextInput();
		Lib.current.addChild(this._textInput);
	}

	public function teardown():Void {
		if (this._textInput != null) {
			if (this._textInput.parent != null) {
				this._textInput.parent.removeChild(this._textInput);
			}
			this._textInput = null;
		}
		FocusManager.dispose();
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, Lib.current.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testSetFocusManagerFocus():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._textInput.validateNow();
		var focusInCount = 0;
		this._textInput.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		focusManager.focus = this._textInput;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._textInput.validateNow();
		var focusInCount = 0;
		this._textInput.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._textInput;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithoutFocusManager():Void {
		this._textInput.validateNow();
		var focusInCount = 0;
		this._textInput.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._textInput;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}
}
