/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.BasicButton)
class StackNavigatorTest extends Test {
	private static final ID_1 = "one";
	private static final ID_2 = "two";

	private var _navigator:StackNavigator;

	public function new() {
		super();
	}

	public function setup():Void {
		this._navigator = new StackNavigator();
		Lib.current.addChild(this._navigator);
	}

	public function teardown():Void {
		if (this._navigator.parent != null) {
			this._navigator.parent.removeChild(this._navigator);
		}
		this._navigator = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._navigator.validateNow();
		this._navigator.dispose();
		this._navigator.dispose();
		Assert.pass();
	}

	public function testInject_withPushItemMethod():Void {
		var injected = false;
		var inject = (view:View1) -> {
			injected = true;
		}
		var view1 = new View1();
		this._navigator.addItem(StackItem.withDisplayObject(ID_1, view1));
		Assert.isFalse(injected);
		this._navigator.pushItem(ID_1, inject);
		Assert.isTrue(injected, "inject must be called with pushItem() method");
	}

	public function testInject_withReplaceItemMethod():Void {
		var injected = false;
		var inject = (view:View2) -> {
			injected = true;
		}
		var view1 = new View1();
		this._navigator.addItem(StackItem.withDisplayObject(ID_1, view1));
		var view2 = new View2();
		this._navigator.addItem(StackItem.withDisplayObject(ID_2, view2));
		this._navigator.rootItemID = ID_1;
		Assert.isFalse(injected);
		Assert.isFalse(injected);
		this._navigator.replaceItem(ID_2, inject);
		Assert.isTrue(injected, "inject must be called with replaceItem() method");
	}

	public function testInject_withPushStackAction():Void {
		var injected = false;
		var inject = (view:View2) -> {
			injected = true;
		}
		var view1 = new View1();
		this._navigator.addItem(StackItem.withDisplayObject(ID_1, view1, [Event.CHANGE => Push(ID_2, inject)]));
		var view2 = new View2();
		this._navigator.addItem(StackItem.withDisplayObject(ID_2, view2));

		this._navigator.rootItemID = ID_1;
		Assert.isFalse(injected);
		view1.dispatchEvent(new Event(Event.CHANGE));
		Assert.isTrue(injected, "inject must be called with StackAction.Push");
	}

	public function testInject_withReplaceStackAction():Void {
		var injected = false;
		var inject = (view:View2) -> {
			injected = true;
		}
		var view1 = new View1();
		this._navigator.addItem(StackItem.withDisplayObject(ID_1, view1, [Event.CHANGE => Replace(ID_2, inject)]));
		var view2 = new View2();
		this._navigator.addItem(StackItem.withDisplayObject(ID_2, view2));

		this._navigator.rootItemID = ID_1;
		Assert.isFalse(injected);
		view1.dispatchEvent(new Event(Event.CHANGE));
		Assert.isTrue(injected, "inject must be called with StackAction.Replace");
	}
}

class View1 extends Sprite {}
class View2 extends Sprite {}
