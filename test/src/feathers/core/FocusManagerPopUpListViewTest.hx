/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.ui.Keyboard;
import feathers.controls.ListView;
import openfl.events.FocusEvent;
import feathers.controls.Button;
import feathers.controls.PopUpListView;
import utest.Assert;
import utest.Test;

@:keep
class FocusManagerPopUpListViewTest extends Test {
	private var _popUpListView:PopUpListView;

	public function new() {
		super();
	}

	public function setup():Void {
		this._popUpListView = new PopUpListView();
		TestMain.openfl_root.addChild(this._popUpListView);
	}

	public function teardown():Void {
		if (this._popUpListView != null) {
			if (this._popUpListView.parent != null) {
				this._popUpListView.parent.removeChild(this._popUpListView);
			}
			this._popUpListView = null;
		}
		FocusManager.dispose();
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, TestMain.openfl_root.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testSetFocusManagerFocus():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		focusManager.focus = this._popUpListView;
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		TestMain.openfl_root.stage.focus = this._popUpListView;
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		TestMain.openfl_root.stage.focus = this._popUpListView;
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${TestMain.openfl_root.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testOpenListViewWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		Assert.equals(focusManager, this._popUpListView.focusManager);
		this._popUpListView.openListView();
		Assert.isTrue((TestMain.openfl_root.stage.focus is ListView),
			'Opening PopUpListView set stage focus to ${TestMain.openfl_root.stage.focus} instead of ListView');
	}

	public function testCloseListViewWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.closeListView();
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Closing PopUpListView set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}

	public function testOpenListThenTabKeyWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, TestMain.openfl_root.stage.focus, false, Keyboard.TAB));
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Pressing Tab key on pop-up list set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}

	public function testOpenListThenShiftPlusTabKeyWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(TestMain.openfl_root.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, TestMain.openfl_root.stage.focus, true, Keyboard.TAB));
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Pressing Shift+Tab key on pop-up list set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}

	public function testOpenListViewWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		Assert.isNull(this._popUpListView.focusManager);
		this._popUpListView.openListView();
		Assert.isTrue((TestMain.openfl_root.stage.focus is ListView),
			'Opening PopUpListView set stage focus to ${TestMain.openfl_root.stage.focus} instead of ListView');
	}

	public function testCloseListViewWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.closeListView();
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Closing PopUpListView set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}

	public function testOpenListThenTabKeyWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		var eventResult = TestMain.openfl_root.stage.focus.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, null, false, Keyboard.TAB));
		Assert.isFalse(eventResult, "Key focus change event was not cancelled");
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Pressing Tab key on pop-up list set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}

	public function testOpenListThenShiftPlusTabKeyWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		var eventResult = TestMain.openfl_root.stage.focus.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, null, true, Keyboard.TAB));
		Assert.isFalse(eventResult, "Key focus change event was not cancelled");
		Assert.isTrue((TestMain.openfl_root.stage.focus is Button),
			'Pressing Shift+Tab key on pop-up list set stage focus to ${TestMain.openfl_root.stage.focus} instead of Button');
	}
}
