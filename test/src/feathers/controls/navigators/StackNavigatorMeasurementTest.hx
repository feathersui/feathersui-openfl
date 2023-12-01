package feathers.controls.navigators;

import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class StackNavigatorMeasurementTest extends Test {
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

	public function testDimensionsAutoSizeStage():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var itemOne = StackItem.withDisplayObject("one", one);
		var itemTwo = StackItem.withDisplayObject("two", two);
		this._navigator.addItem(itemOne);
		this._navigator.addItem(itemTwo);
		this._navigator.autoSizeMode = STAGE;
		this._navigator.rootItemID = itemOne.id;
		this._navigator.validateNow();
		Assert.equals(Lib.current.stage.stageWidth, one.width);
		Assert.equals(Lib.current.stage.stageHeight, one.height);
		Assert.equals(Lib.current.stage.stageWidth, this._navigator.width);
		Assert.equals(Lib.current.stage.stageHeight, this._navigator.height);
	}

	public function testDimensionsAutoSizeContent():Void {
		final WIDTH1 = 120.0;
		final WIDTH2 = 100.0;
		var one = new LayoutGroup();
		one.width = WIDTH1;
		one.height = WIDTH2;
		var two = new LayoutGroup();
		two.width = 200.0;
		two.height = 150.0;
		var itemOne = StackItem.withDisplayObject("one", one);
		var itemTwo = StackItem.withDisplayObject("two", two);
		this._navigator.addItem(itemOne);
		this._navigator.addItem(itemTwo);
		this._navigator.autoSizeMode = CONTENT;
		this._navigator.rootItemID = itemOne.id;

		this._navigator.validateNow();
		Assert.equals(WIDTH1, one.width);
		Assert.equals(WIDTH2, one.height);
		Assert.equals(one.width, this._navigator.width);
		Assert.equals(one.height, this._navigator.height);
	}
}
