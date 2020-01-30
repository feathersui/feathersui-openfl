/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.MouseEvent;
import openfl.events.Event;
import feathers.controls.ToggleSwitch;
import massive.munit.Assert;

@:keep
class ToggleSwitchTest {
	private var _toggle:ToggleSwitch;

	@Before
	public function prepare():Void {
		this._toggle = new ToggleSwitch();
		TestMain.openfl_root.addChild(this._toggle);
	}

	@After
	public function cleanup():Void {
		if (this._toggle.parent != null) {
			this._toggle.parent.removeChild(this._toggle);
		}
		this._toggle = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testProgrammaticSelectionChange():Void {
		this._toggle.selected = false;
		var changed = false;
		this._toggle.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._toggle.selected = true;
		Assert.isTrue(changed, "Event.CHANGE must be dispatched when changing selected property");
	}

	@Test
	public function testInteractiveSelectionChangeOnClick():Void {
		this._toggle.selected = false;
		var changed = false;
		this._toggle.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._toggle.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isTrue(this._toggle.selected, "selected property must change on click");
		Assert.isTrue(changed, "Event.CHANGE must be dispatched on click");
	}

	@Test
	public function testNoInteractiveSelectionChangeOnClickWhenDisabled():Void {
		this._toggle.selected = false;
		this._toggle.enabled = false;
		var changed = false;
		this._toggle.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._toggle.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isFalse(this._toggle.selected, "selected property must not change on click when disabled");
		Assert.isFalse(changed, "Event.CHANGE must not be dispatched on click when disabled");
	}

	@Test
	public function testInteractiveSelectionChangeOnDrag():Void {
		this._toggle.selected = false;
		var changed = false;
		this._toggle.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._toggle.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		this._toggle.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, true, 1000));
		Assert.isTrue(this._toggle.selected, "selected property must change on click");
		Assert.isTrue(changed, "Event.CHANGE must be dispatched on click");
	}
}
