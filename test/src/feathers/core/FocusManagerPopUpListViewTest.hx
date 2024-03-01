/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.Button;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import openfl.Lib;
import openfl.events.FocusEvent;
import openfl.ui.Keyboard;
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
		Lib.current.addChild(this._popUpListView);
	}

	public function teardown():Void {
		if (this._popUpListView != null) {
			if (this._popUpListView.parent != null) {
				this._popUpListView.parent.removeChild(this._popUpListView);
			}
			this._popUpListView = null;
		}
		FocusManager.dispose();
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, Lib.current.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testSetFocusManagerFocus():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		focusManager.focus = this._popUpListView;
		Assert.isTrue((Lib.current.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._popUpListView;
		Assert.isTrue((Lib.current.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		var focusInCount = 0;
		this._popUpListView.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._popUpListView;
		Assert.isTrue((Lib.current.stage.focus is Button),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of Button');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testOpenListViewWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		Assert.equals(focusManager, this._popUpListView.focusManager);
		this._popUpListView.openListView();
		Assert.isTrue((Lib.current.stage.focus is ListView), 'Opening PopUpListView set stage focus to ${Lib.current.stage.focus} instead of ListView');
	}

	public function testCloseListViewWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.closeListView();
		Assert.isTrue((Lib.current.stage.focus is Button), 'Closing PopUpListView set stage focus to ${Lib.current.stage.focus} instead of Button');
	}

	public function testOpenListThenTabKeyWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, Lib.current.stage.focus, false, Keyboard.TAB));
		Assert.isTrue((Lib.current.stage.focus is Button), 'Pressing Tab key on pop-up list set stage focus to ${Lib.current.stage.focus} instead of Button');
	}

	public function testOpenListThenShiftPlusTabKeyWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, Lib.current.stage.focus, true, Keyboard.TAB));
		Assert.isTrue((Lib.current.stage.focus is Button),
			'Pressing Shift+Tab key on pop-up list set stage focus to ${Lib.current.stage.focus} instead of Button');
	}

	public function testOpenListViewWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		Assert.isNull(this._popUpListView.focusManager);
		this._popUpListView.openListView();
		Assert.isTrue((Lib.current.stage.focus is ListView), 'Opening PopUpListView set stage focus to ${Lib.current.stage.focus} instead of ListView');
	}

	public function testCloseListViewWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		this._popUpListView.closeListView();
		Assert.isTrue((Lib.current.stage.focus is Button), 'Closing PopUpListView set stage focus to ${Lib.current.stage.focus} instead of Button');
	}

	public function testOpenListThenTabKeyWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		var eventResult = Lib.current.stage.focus.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, null, false, Keyboard.TAB));
		Assert.isFalse(eventResult, "Key focus change event was not cancelled");
		Assert.isTrue((Lib.current.stage.focus is Button), 'Pressing Tab key on pop-up list set stage focus to ${Lib.current.stage.focus} instead of Button');
	}

	public function testOpenListThenShiftPlusTabKeyWithoutFocusManager():Void {
		this._popUpListView.validateNow();
		this._popUpListView.openListView();
		var eventResult = Lib.current.stage.focus.dispatchEvent(new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE, true, true, null, true, Keyboard.TAB));
		Assert.isFalse(eventResult, "Key focus change event was not cancelled");
		Assert.isTrue((Lib.current.stage.focus is Button),
			'Pressing Shift+Tab key on pop-up list set stage focus to ${Lib.current.stage.focus} instead of Button');
	}
}
