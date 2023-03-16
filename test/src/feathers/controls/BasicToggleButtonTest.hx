/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.TriggerEvent;
import openfl.Lib;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.BasicToggleButton)
class BasicToggleButtonTest extends Test {
	private var _button:BasicToggleButton;

	public function new() {
		super();
	}

	public function setup():Void {
		this._button = new BasicToggleButton();
		Lib.current.addChild(this._button);
	}

	public function teardown():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testDispatchTriggerOnClick():Void {
		var triggered = false;
		this._button.addEventListener(TriggerEvent.TRIGGER, function(event:Event):Void {
			triggered = true;
		});
		Assert.isFalse(triggered);
		this._button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isTrue(triggered, "TriggerEvent.TRIGGER must be dispatched after MouseEvent.CLICK");
	}

	#if (openfl >= "9.0.0")
	public function testDispatchTriggerOnTouchTap():Void {
		var triggered = false;
		this._button.addEventListener(TriggerEvent.TRIGGER, function(event:Event):Void {
			triggered = true;
		});
		Assert.isFalse(triggered);
		this._button.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.isTrue(triggered, "TriggerEvent.TRIGGER must be dispatched after TouchEvent.TOUCH_TAP");
	}
	#end

	public function testClickWhenDisabled():Void {
		var clicked = false;
		this._button.addEventListener(MouseEvent.CLICK, function(event:Event):Void {
			clicked = true;
		});
		var triggered = false;
		this._button.addEventListener(TriggerEvent.TRIGGER, function(event:Event):Void {
			triggered = true;
		});
		this._button.enabled = false;
		this._button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isFalse(clicked, "MouseEvent.CLICK must be stopped from propagating when disabled");
		Assert.isFalse(triggered, "TriggerEvent.TRIGGER must be not be dispatched when disabled");
	}

	public function testTouchTapWhenDisabled():Void {
		var clicked = false;
		this._button.addEventListener(TouchEvent.TOUCH_TAP, function(event:Event):Void {
			clicked = true;
		});
		var triggered = false;
		this._button.addEventListener(TriggerEvent.TRIGGER, function(event:Event):Void {
			triggered = true;
		});
		this._button.enabled = false;
		this._button.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.isFalse(clicked, "TouchEvent.TOUCH_TAP must be stopped from propagating when disabled");
		Assert.isFalse(triggered, "TriggerEvent.TRIGGER must be not be dispatched when disabled");
	}

	public function testDispatchChangeEventOnSetSelected():Void {
		var changed = false;
		this._button.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(this._button.selected);
		Assert.isFalse(changed);
		this._button.selected = true;
		Assert.isTrue(changed);
		Assert.isTrue(this._button.selected);
	}

	public function testDispatchChangeEventOnClick():Void {
		var changed = false;
		this._button.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(this._button.selected);
		Assert.isFalse(changed);
		this._button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isTrue(changed);
		Assert.isTrue(this._button.selected);
	}

	#if (openfl >= "9.0.0")
	public function testDispatchChangeEventOnTouchTap():Void {
		var changed = false;
		this._button.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(this._button.selected);
		Assert.isFalse(changed);
		this._button.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.isTrue(changed);
		Assert.isTrue(this._button.selected);
	}
	#end

	public function testDoesNotDispatchChangeEventOnClickWhenNotToggleable():Void {
		var changed = false;
		this._button.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._button.toggleable = false;
		Assert.isFalse(this._button.selected);
		Assert.isFalse(changed);
		this._button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isFalse(changed);
		Assert.isFalse(this._button.selected);
	}

	public function testDoesNotDispatchChangeEventOnTouchTapWhenNotToggleable():Void {
		var changed = false;
		this._button.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		this._button.toggleable = false;
		Assert.isFalse(this._button.selected);
		Assert.isFalse(changed);
		this._button.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.isFalse(changed);
		Assert.isFalse(this._button.selected);
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin2;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._button, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._button.backgroundSkin = skin;
		this._button.validateNow();
		Assert.equals(this._button, skin.parent);
		this._button.backgroundSkin = null;
		this._button.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.setSkinForState(ToggleButtonState.DISABLED(false), skin2);
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.enabled = false;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._button, skin2.parent);
	}

	public function testRemoveSkinAfterSelect():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.selectedBackgroundSkin = skin2;
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.selected = true;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._button, skin2.parent);
	}

	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.setSkinForState(ToggleButtonState.DOWN(false), skin2);
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.changeState(ToggleButtonState.DOWN(false));
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._button, skin2.parent);
	}
}
