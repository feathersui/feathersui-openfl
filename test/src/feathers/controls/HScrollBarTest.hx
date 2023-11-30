/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class HScrollBarTest extends Test {
	private var _scrollBar:HScrollBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._scrollBar = new HScrollBar();
		Lib.current.addChild(this._scrollBar);
	}

	public function teardown():Void {
		if (this._scrollBar.parent != null) {
			this._scrollBar.parent.removeChild(this._scrollBar);
		}
		this._scrollBar = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._scrollBar.validateNow();
		this._scrollBar.dispose();
		this._scrollBar.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetValue():Void {
		this._scrollBar.value = 0.5;
		var changed = false;
		this._scrollBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(0.5, this._scrollBar.value);
		Assert.isFalse(changed);
		this._scrollBar.value = 1.0;
		Assert.isTrue(changed);
		Assert.equals(1.0, this._scrollBar.value);
	}

	public function testSnapInterval():Void {
		this._scrollBar.minimum = -1.0;
		this._scrollBar.maximum = 1.0;
		this._scrollBar.snapInterval = 0.3;

		// round up
		this._scrollBar.value = 0.2;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(0.3, this._scrollBar.value);
		// round down
		this._scrollBar.value = 0.7;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(0.6, this._scrollBar.value);

		// allow maximum, even if not on interval
		this._scrollBar.value = 1.0;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(1.0, this._scrollBar.value);
		// allow minimum, even if not on interval
		this._scrollBar.value = -1.0;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(-1.0, this._scrollBar.value);
	}

	public function testDecrementAndIncrementButtonDefaultVariants():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = true;
		this._scrollBar.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(HScrollBar.CHILD_VARIANT_DECREMENT_BUTTON, decrementButton.variant);
		Assert.notNull(incrementButton);
		Assert.equals(HScrollBar.CHILD_VARIANT_INCREMENT_BUTTON, incrementButton.variant);
	}

	public function testDecrementAndIncrementButtonCustomVariants1():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		final customDecrementVariant = "custom1";
		final customIncrementVariant = "custom2";
		this._scrollBar.customDecrementButtonVariant = customDecrementVariant;
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._scrollBar.customIncrementButtonVariant = customIncrementVariant;
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = true;
		this._scrollBar.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customDecrementVariant, decrementButton.variant);
		Assert.notNull(incrementButton);
		Assert.equals(customIncrementVariant, incrementButton.variant);
	}

	public function testDecrementAndIncrementButtonCustomVariants2():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		final customDecrementVariant = "custom1";
		final customIncrementVariant = "custom2";
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			decrementButton.variant = customDecrementVariant;
			return decrementButton;
		}
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			incrementButton.variant = customIncrementVariant;
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = true;
		this._scrollBar.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customDecrementVariant, decrementButton.variant);
		Assert.notNull(incrementButton);
		Assert.equals(customIncrementVariant, incrementButton.variant);
	}

	public function testDecrementAndIncrementButtonCustomVariants3():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		final customDecrementVariant1 = "custom1";
		final customIncrementVariant1 = "custom2";
		final customDecrementVariant2 = "custom3";
		final customIncrementVariant2 = "custom4";
		this._scrollBar.customDecrementButtonVariant = customDecrementVariant1;
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			decrementButton.variant = customDecrementVariant2;
			return decrementButton;
		}
		this._scrollBar.customIncrementButtonVariant = customIncrementVariant1;
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			incrementButton.variant = customIncrementVariant2;
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = true;
		this._scrollBar.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customDecrementVariant2, decrementButton.variant);
		Assert.notNull(incrementButton);
		Assert.equals(customIncrementVariant2, incrementButton.variant);
	}

	public function testShowDecrementAndIncrementButtons():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = true;
		this._scrollBar.validateNow();
		Assert.notNull(decrementButton);
		Assert.notNull(decrementButton.parent);
		Assert.isTrue(decrementButton.visible);
		Assert.notNull(incrementButton);
		Assert.notNull(incrementButton.parent);
		Assert.isTrue(incrementButton.visible);
	}

	public function testHideDecrementAndIncrementButtons():Void {
		var decrementButton:Button = null;
		var incrementButton:Button = null;
		this._scrollBar.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._scrollBar.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._scrollBar.showDecrementAndIncrementButtons = false;
		this._scrollBar.validateNow();
		// exactly how the buttons are hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(decrementButton == null || decrementButton.parent == null || !decrementButton.visible);
		Assert.isTrue(incrementButton == null || incrementButton.parent == null || !incrementButton.visible);
	}
}
