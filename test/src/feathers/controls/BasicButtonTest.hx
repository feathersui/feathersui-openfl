/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.TouchEvent;
import feathers.events.TriggerEvent;
import openfl.display.Shape;
import openfl.events.MouseEvent;
import openfl.events.Event;
import feathers.controls.BasicButton;
import feathers.events.FeathersEvent;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.BasicButton)
class BasicButtonTest extends Test {
	private var _button:BasicButton;

	public function new() {
		super();
	}

	public function setup():Void {
		this._button = new BasicButton();
		TestMain.openfl_root.addChild(this._button);
	}

	public function teardown():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
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

	public function testDefaultsToButtonStateUp():Void {
		Assert.equals(ButtonState.UP, this._button.currentState, "currentState must default to ButtonState.UP");
	}

	public function testButtonStateDisabled():Void {
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.DISABLED) {
				stateChanged = true;
			}
		});
		this._button.enabled = false;
		Assert.equals(ButtonState.DISABLED, this._button.currentState, "currentState must be ButtonState.DISABLED when enabled property is false");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.DISABLED");
	}

	public function testButtonStateHoverAfterRollOver():Void {
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.HOVER) {
				stateChanged = true;
			}
		});
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		Assert.equals(ButtonState.HOVER, this._button.currentState, "currentState must be ButtonState.HOVER on MouseEvent.ROLL_OVER");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.HOVER");
	}

	public function testButtonStateUpAfterRollOut():Void {
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.UP) {
				stateChanged = true;
			}
		});
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
		Assert.equals(ButtonState.UP, this._button.currentState, "currentState must be ButtonState.UP on MouseEvent.ROLL_OUT");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.UP");
	}

	public function testButtonStateDownAfterMouseDown():Void {
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.DOWN) {
				stateChanged = true;
			}
		});
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		Assert.equals(ButtonState.DOWN, this._button.currentState, "currentState must be ButtonState.DOWN on MouseEvent.MOUSE_DOWN");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.DOWN");
	}

	public function testButtonStateDisabledAfterMouseDownWhenNotEnabled():Void {
		this._button.enabled = false;
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		Assert.equals(ButtonState.DISABLED, this._button.currentState,
			"currentState must be ButtonState.DISABLED on MouseEvent.MOUSE_DOWN when enabled property is false");
	}

	public function testButtonStateUpAfterMouseDownAndRemovedFromStage():Void {
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.UP) {
				stateChanged = true;
			}
		});
		this._button.parent.removeChild(this._button);
		Assert.equals(ButtonState.UP, this._button.currentState, "currentState must be ButtonState.UP on Event.REMOVED_FROM_STAGE");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.UP");
	}

	public function testButtonStateUpAfterMouseDownAndRollOut():Void {
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.UP) {
				stateChanged = true;
			}
		});
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
		Assert.equals(ButtonState.UP, this._button.currentState, "currentState must be ButtonState.UP on MouseEvent.MOUSE_DOWN and MouseEvent.ROLL_OUT");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.UP");
	}

	public function testButtonStateDownAfterMouseDownAndRollOutWithKeepDownStateOnRollOut():Void {
		this._button.keepDownStateOnRollOut = true;
		// need to validate to pass this value down to PointerToState
		this._button.validateNow();
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
		Assert.equals(ButtonState.DOWN, this._button.currentState,
			"currentState must be ButtonState.DOWN on MouseEvent.MOUSE_DOWN and MouseEvent.ROLL_OUT when keepDownStateOnRollOut is true");
	}

	public function testButtonStateDownAfterMouseDownRollOutAndRollOver():Void {
		this._button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
		var stateChanged = false;
		this._button.addEventListener(FeathersEvent.STATE_CHANGE, function(event:FeathersEvent):Void {
			if (this._button.currentState == ButtonState.DOWN) {
				stateChanged = true;
			}
		});
		this._button.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		Assert.equals(ButtonState.DOWN, this._button.currentState,
			"currentState must be ButtonState.DOWN on MouseEvent.MOUSE_DOWN, MouseEvent.ROLL_OUT, and MouseEvent.ROLL_OVER");
		Assert.isTrue(stateChanged, "FeathersEvent.STATE_CHANGE must be dispatched when state is changed to ButtonState.UP");
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
		this._button.setSkinForState(ButtonState.DISABLED, skin2);
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.enabled = false;
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
		this._button.setSkinForState(ButtonState.DOWN, skin2);
		this._button.validateNow();
		Assert.equals(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.changeState(ButtonState.DOWN);
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._button, skin2.parent);
	}
}
