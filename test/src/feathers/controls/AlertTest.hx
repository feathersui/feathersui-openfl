/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class AlertTest extends Test {
	private var _alert:Alert;

	public function new() {
		super();
	}

	public function setup():Void {
		this._alert = new Alert();
		Lib.current.addChild(this._alert);
	}

	public function teardown():Void {
		if (this._alert.parent != null) {
			this._alert.parent.removeChild(this._alert);
		}
		this._alert = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._alert.validateNow();
		this._alert.dispose();
		this._alert.dispose();
		Assert.pass();
	}

	public function testButtonBarDefaultVariant():Void {
		var buttonBar:ButtonBar = null;
		this._alert.buttonBarFactory = () -> {
			buttonBar = new ButtonBar();
			return buttonBar;
		}
		this._alert.validateNow();
		Assert.notNull(buttonBar);
		Assert.equals(Alert.CHILD_VARIANT_BUTTON_BAR, buttonBar.variant);
	}

	public function testButtonBarCustomVariant1():Void {
		final customVariant = "custom";
		this._alert.customButtonBarVariant = customVariant;
		var buttonBar:ButtonBar = null;
		this._alert.buttonBarFactory = () -> {
			buttonBar = new ButtonBar();
			return buttonBar;
		}
		this._alert.validateNow();
		Assert.notNull(buttonBar);
		Assert.equals(customVariant, buttonBar.variant);
	}

	public function testButtonBarCustomVariant2():Void {
		final customVariant = "custom";
		var buttonBar:ButtonBar = null;
		this._alert.buttonBarFactory = () -> {
			buttonBar = new ButtonBar();
			buttonBar.variant = customVariant;
			return buttonBar;
		}
		this._alert.validateNow();
		Assert.notNull(buttonBar);
		Assert.equals(customVariant, buttonBar.variant);
	}

	public function testButtonBarCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._alert.customButtonBarVariant = customVariant1;
		var buttonBar:ButtonBar = null;
		this._alert.buttonBarFactory = () -> {
			buttonBar = new ButtonBar();
			buttonBar.variant = customVariant2;
			return buttonBar;
		}
		this._alert.validateNow();
		Assert.notNull(buttonBar);
		Assert.equals(customVariant2, buttonBar.variant);
	}
}
