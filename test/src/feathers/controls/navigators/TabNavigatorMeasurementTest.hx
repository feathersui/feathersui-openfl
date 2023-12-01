package feathers.controls.navigators;

import feathers.data.ArrayCollection;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class TabNavigatorMeasurementTest extends Test {
	private var _navigator:TabNavigator;

	public function new() {
		super();
	}

	public function setup():Void {
		this._navigator = new TabNavigator();
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
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.autoSizeMode = STAGE;
		this._navigator.tabBarPosition = TOP;
		this._navigator.validateNow();
		Assert.equals(Lib.current.stage.stageWidth, this._navigator.width);
		Assert.equals(Lib.current.stage.stageHeight, this._navigator.height);
	}

	public function testDimensionsAutoSizeContentSmallerContentWidth():Void {
		final GAP = 10.0;
		var one = new LayoutGroup();
		one.width = 10.0;
		one.height = 100.0;
		var two = new LayoutGroup();
		two.width = 10.0;
		two.height = 150.0;
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.autoSizeMode = CONTENT;
		this._navigator.gap = GAP;
		this._navigator.tabBarPosition = TOP;
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			return tabBar;
		}

		this._navigator.validateNow();
		Assert.isTrue(tabBar.width > 0.0);
		Assert.isTrue(tabBar.height > 0.0);
		Assert.equals(tabBar.width, this._navigator.width);
		Assert.equals(tabBar.height + GAP + one.height, this._navigator.height);
	}

	public function testDimensionsAutoSizeContentLargerContentWidth():Void {
		final GAP = 10.0;
		var one = new LayoutGroup();
		one.width = 1000.0;
		one.height = 100.0;
		var two = new LayoutGroup();
		two.width = 1000.0;
		two.height = 150.0;
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.autoSizeMode = CONTENT;
		this._navigator.gap = GAP;
		this._navigator.tabBarPosition = TOP;
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			return tabBar;
		}

		this._navigator.validateNow();
		Assert.isTrue(tabBar.width > 0.0);
		Assert.isTrue(tabBar.height > 0.0);
		Assert.equals(one.width, this._navigator.width);
		Assert.equals(tabBar.height + GAP + one.height, this._navigator.height);
	}
}
