/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.navigators;

import openfl.display.Sprite;
import openfl.events.Event;
import feathers.events.FeathersEvent;
import massive.munit.Assert;

@:keep
@:access(feathers.controls.BasicButton)
class StackNavigatorTest {
	private static final ID_1 = "one";
	private static final ID_2 = "two";

	private var _navigator:StackNavigator;

	@Before
	public function prepare():Void {
		this._navigator = new StackNavigator();
		TestMain.openfl_root.addChild(this._navigator);
	}

	@After
	public function cleanup():Void {
		if (this._navigator.parent != null) {
			this._navigator.parent.removeChild(this._navigator);
		}
		this._navigator = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
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

	@Test
	public function testInject_withReplaceItemMethod():Void {
		var injected = false;
		var inject = (view:View1) -> {
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

	@Test
	public function testInject_withPushStackAction():Void {
		var injected = false;
		var inject = (view:View1) -> {
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

	@Test
	public function testInject_withReplaceStackAction():Void {
		var injected = false;
		var inject = (view:View1) -> {
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
