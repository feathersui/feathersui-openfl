/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.controls.LayoutGroup;
import utest.Assert;
import utest.Test;

@:keep
class ClassVariantStyleProviderTest extends Test {
	private static final VARIANT_ONE = "one";
	private static final VARIANT_TWO = "two";

	private var _control:LayoutGroup;
	private var _styleProvider:ClassVariantStyleProvider;
	private var _defaultCalled:Bool;
	private var _oneCalled:Bool;
	private var _twoCalled:Bool;

	public function new() {
		super();
	}

	public function setup():Void {
		this._defaultCalled = false;
		this._oneCalled = false;
		this._twoCalled = false;

		this._styleProvider = new ClassVariantStyleProvider();
		this._control = new LayoutGroup();
	}

	public function teardown():Void {
		this._control = null;
		this._styleProvider = null;
		this._defaultCalled = false;
		this._oneCalled = false;
		this._twoCalled = false;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function defaultFunction(target:LayoutGroup):Void {
		this._defaultCalled = true;
	}

	private function oneFunction(target:LayoutGroup):Void {
		this._oneCalled = true;
	}

	private function twoFunction(target:LayoutGroup):Void {
		this._twoCalled = true;
	}

	public function testNoErrorWithNullDefaultFunction():Void {
		this._styleProvider.applyStyles(this._control);
		Assert.isFalse(this._defaultCalled, "Default function must not be called when not used");
	}

	public function testDefaultFunctionCalled_VariantNotSet_VariantNotRegistered():Void {
		this._styleProvider.setStyleFunction(LayoutGroup, null, defaultFunction);
		this._styleProvider.applyStyles(this._control);
		Assert.isTrue(this._defaultCalled, "Default function must be called");
		Assert.isFalse(this._oneCalled, "Variant function one must not be called when it is not registered");
		Assert.isFalse(this._twoCalled, "Variant function two must not be called when it is not registered");
	}

	public function testDefaultFunctionCalled_VariantSet_VariantNotRegistered():Void {
		this._styleProvider.setStyleFunction(LayoutGroup, null, defaultFunction);
		this._control.variant = VARIANT_ONE;
		this._styleProvider.applyStyles(this._control);
		Assert.isTrue(this._defaultCalled, "Default function must be called");
		Assert.isFalse(this._oneCalled, "Variant function one must not be called when it is not registered");
		Assert.isFalse(this._twoCalled, "Variant function two must not be called when it is not registered");
	}

	public function testDefaultFunctionCalled_VariantNotSet_VariantRegistered():Void {
		this._styleProvider.setStyleFunction(LayoutGroup, null, defaultFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_ONE, oneFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_TWO, twoFunction);
		this._styleProvider.applyStyles(this._control);
		Assert.isTrue(this._defaultCalled, "Default function must be called");
		Assert.isFalse(this._oneCalled, "Variant function one must not be called when target has no variant");
		Assert.isFalse(this._twoCalled, "Variant function two must not be called when target has no variant");
	}

	public function testVariantOneFunctionCalled_VariantSet_VariantRegistered():Void {
		this._styleProvider.setStyleFunction(LayoutGroup, null, defaultFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_ONE, oneFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_TWO, twoFunction);
		this._control.variant = VARIANT_ONE;
		this._styleProvider.applyStyles(this._control);
		Assert.isFalse(this._defaultCalled, "Default function must not be called when variant one matches");
		Assert.isTrue(this._oneCalled, "Variant function one must be called when variant one matches");
		Assert.isFalse(this._twoCalled, "Variant function two must not be called when variant one matchs");
	}

	public function testVariantTwoFunctionCalled_VariantSet_VariantRegistered():Void {
		this._styleProvider.setStyleFunction(LayoutGroup, null, defaultFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_ONE, oneFunction);
		this._styleProvider.setStyleFunction(LayoutGroup, VARIANT_TWO, twoFunction);
		this._control.variant = VARIANT_TWO;
		this._styleProvider.applyStyles(this._control);
		Assert.isFalse(this._defaultCalled, "Default function must not be called when variant two matches");
		Assert.isFalse(this._oneCalled, "Variant function one must not be called when variant two matches");
		Assert.isTrue(this._twoCalled, "Variant function two must be called when variant two matches");
	}
}
