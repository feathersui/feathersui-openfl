/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ArrayCollection;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class FormTest extends Test {
	private var _form:Form;

	public function new() {
		super();
	}

	public function setup():Void {
		this._form = new Form();
		Lib.current.addChild(this._form);
	}

	public function teardown():Void {
		if (this._form.parent != null) {
			this._form.parent.removeChild(this._form);
		}
		this._form = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._form.validateNow();
		this._form.dispose();
		this._form.dispose();
		Assert.pass();
	}
}
