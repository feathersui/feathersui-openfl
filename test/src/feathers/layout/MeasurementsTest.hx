/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import feathers.layout.Measurements;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class MeasurementsTest extends Test {
	private var _measurements:Measurements;
	private var _control:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._measurements = new Measurements();
		this._control = new LayoutGroup();
		Lib.current.addChild(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		this._measurements = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testDefaults():Void {
		Assert.isNull(this._measurements.width, "The measurements width must default to null");
		Assert.isNull(this._measurements.height, "The measurements height must default to null");
		Assert.isNull(this._measurements.minWidth, "The measurements minWidth must default to null");
		Assert.isNull(this._measurements.minHeight, "The measurements minHeight must default to null");
		Assert.isNull(this._measurements.maxWidth, "The measurements maxWidth must default to null");
		Assert.isNull(this._measurements.maxHeight, "The measurements maxHeight must default to null");
	}

	public function testDefaultsAfterSave():Void {
		this._measurements.save(this._control);
		Assert.isNull(this._measurements.width, "The measurements width must be null if explicitWidth is null");
		Assert.isNull(this._measurements.height, "The measurements height must be null if explicitHeight is null");
		Assert.isNull(this._measurements.minWidth, "The measurements minWidth must be null if explicitMinWidth is null");
		Assert.isNull(this._measurements.minHeight, "The measurements minHeight must be null if explicitMinHeight is null");
		Assert.isNull(this._measurements.maxWidth, "The measurements maxWidth must be null if explicitMaxWidth is null");
		Assert.isNull(this._measurements.maxHeight, "The measurements maxHeight must be null if explicitMaxHeight is null");
	}

	public function testSave():Void {
		this._control.width = 10.0;
		this._control.height = 15.0;
		this._control.minWidth = 1.0;
		this._control.minHeight = 2.0;
		this._control.maxWidth = 100.0;
		this._control.maxHeight = 200.0;
		this._measurements.save(this._control);
		Assert.equals(this._control.explicitWidth, this._measurements.width, "The measurements width must be equal to explicitWidth");
		Assert.equals(this._control.explicitHeight, this._measurements.height, "The measurements height must be equal to explicitHeight");
		Assert.equals(this._control.explicitMinWidth, this._measurements.minWidth, "The measurements minWidth must be equal to explicitMinWidth");
		Assert.equals(this._control.explicitMinHeight, this._measurements.minHeight, "The measurements minHeight must equal to if explicitMinHeight");
		Assert.equals(this._control.explicitMaxWidth, this._measurements.maxWidth, "The measurements maxWidth must be equal to explicitMaxWidth");
		Assert.equals(this._control.explicitMaxHeight, this._measurements.maxHeight, "The measurements maxHeight must be equal to explicitMaxHeight");
	}

	public function testRestore():Void {
		this._measurements.width = 10.0;
		this._measurements.height = 15.0;
		this._measurements.minWidth = 1.0;
		this._measurements.minHeight = 2.0;
		this._measurements.maxWidth = 100.0;
		this._measurements.maxHeight = 200.0;
		this._measurements.restore(this._control);
		Assert.equals(this._control.explicitWidth, this._measurements.width, "The measurements width must be equal to explicitWidth");
		Assert.equals(this._control.explicitHeight, this._measurements.height, "The measurements height must be equal to explicitHeight");
		Assert.equals(this._control.explicitMinWidth, this._measurements.minWidth, "The measurements minWidth must be equal to explicitMinWidth");
		Assert.equals(this._control.explicitMinHeight, this._measurements.minHeight, "The measurements minHeight must equal to if explicitMinHeight");
		Assert.equals(this._control.explicitMaxWidth, this._measurements.maxWidth, "The measurements maxWidth must be equal to explicitMaxWidth");
		Assert.equals(this._control.explicitMaxHeight, this._measurements.maxHeight, "The measurements maxHeight must be equal to explicitMaxHeight");
	}
}
