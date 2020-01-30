/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.layout.Measurements;
import feathers.controls.LayoutGroup;
import massive.munit.Assert;

@:keep
class MeasurementsTest {
	private var _measurements:Measurements;
	private var _control:LayoutGroup;

	@Before
	public function prepare():Void {
		this._measurements = new Measurements();
		this._control = new LayoutGroup();
		TestMain.openfl_root.addChild(this._control);
	}

	@After
	public function cleanup():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		this._measurements = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testDefaults():Void {
		Assert.isNull(this._measurements.width, "The measurements width must default to null");
		Assert.isNull(this._measurements.height, "The measurements height must default to null");
		Assert.isNull(this._measurements.minWidth, "The measurements minWidth must default to null");
		Assert.isNull(this._measurements.minHeight, "The measurements minHeight must default to null");
		Assert.isNull(this._measurements.maxWidth, "The measurements maxWidth must default to null");
		Assert.isNull(this._measurements.maxHeight, "The measurements maxHeight must default to null");
	}

	@Test
	public function testDefaultsAfterSave():Void {
		this._measurements.save(this._control);
		Assert.isNull(this._measurements.width, "The measurements width must be null if explicitWidth is null");
		Assert.isNull(this._measurements.height, "The measurements height must be null if explicitHeight is null");
		Assert.isNull(this._measurements.minWidth, "The measurements minWidth must be null if explicitMinWidth is null");
		Assert.isNull(this._measurements.minHeight, "The measurements minHeight must be null if explicitMinHeight is null");
		Assert.isNull(this._measurements.maxWidth, "The measurements maxWidth must be null if explicitMaxWidth is null");
		Assert.isNull(this._measurements.maxHeight, "The measurements maxHeight must be null if explicitMaxHeight is null");
	}

	@Test
	public function testSave():Void {
		this._control.width = 10.0;
		this._control.height = 15.0;
		this._control.minWidth = 1.0;
		this._control.minHeight = 2.0;
		this._control.maxWidth = 100.0;
		this._control.maxHeight = 200.0;
		this._measurements.save(this._control);
		Assert.areEqual(this._control.explicitWidth, this._measurements.width, "The measurements width must be equal to explicitWidth");
		Assert.areEqual(this._control.explicitHeight, this._measurements.height, "The measurements height must be equal to explicitHeight");
		Assert.areEqual(this._control.explicitMinWidth, this._measurements.minWidth, "The measurements minWidth must be equal to explicitMinWidth");
		Assert.areEqual(this._control.explicitMinHeight, this._measurements.minHeight, "The measurements minHeight must equal to if explicitMinHeight");
		Assert.areEqual(this._control.explicitMaxWidth, this._measurements.maxWidth, "The measurements maxWidth must be equal to explicitMaxWidth");
		Assert.areEqual(this._control.explicitMaxHeight, this._measurements.maxHeight, "The measurements maxHeight must be equal to explicitMaxHeight");
	}

	@Test
	public function testRestore():Void {
		this._measurements.width = 10.0;
		this._measurements.height = 15.0;
		this._measurements.minWidth = 1.0;
		this._measurements.minHeight = 2.0;
		this._measurements.maxWidth = 100.0;
		this._measurements.maxHeight = 200.0;
		this._measurements.restore(this._control);
		Assert.areEqual(this._control.explicitWidth, this._measurements.width, "The measurements width must be equal to explicitWidth");
		Assert.areEqual(this._control.explicitHeight, this._measurements.height, "The measurements height must be equal to explicitHeight");
		Assert.areEqual(this._control.explicitMinWidth, this._measurements.minWidth, "The measurements minWidth must be equal to explicitMinWidth");
		Assert.areEqual(this._control.explicitMinHeight, this._measurements.minHeight, "The measurements minHeight must equal to if explicitMinHeight");
		Assert.areEqual(this._control.explicitMaxWidth, this._measurements.maxWidth, "The measurements maxWidth must be equal to explicitMaxWidth");
		Assert.areEqual(this._control.explicitMaxHeight, this._measurements.maxHeight, "The measurements maxHeight must be equal to explicitMaxHeight");
	}
}
