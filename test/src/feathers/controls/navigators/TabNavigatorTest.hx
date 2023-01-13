package feathers.controls.navigators;

import feathers.data.ArrayCollection;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class TabNavigatorTest extends Test {
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

	public function testValidateWithNoDataProvider():Void {
		this._navigator.validateNow();
		Assert.equals(-1, this._navigator.selectedIndex);
		Assert.isNull(this._navigator.selectedItem);
		Assert.isNull(this._navigator.activeItemView);
	}

	public function testDefaultSelectedIndex():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(tabOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
	}

	public function testSetSelectedIndex():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.selectedIndex = 1;
		this._navigator.validateNow();
		Assert.equals(1, this._navigator.selectedIndex);
		Assert.equals(tabTwo, this._navigator.selectedItem);
		Assert.equals(two, this._navigator.activeItemView);
	}

	public function testSetSelectedItem():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.selectedItem = tabTwo;
		this._navigator.validateNow();
		Assert.equals(1, this._navigator.selectedIndex);
		Assert.equals(tabTwo, this._navigator.selectedItem);
		Assert.equals(two, this._navigator.activeItemView);
	}

	public function testValidateWithDataProviderThenNoDataProvider():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var tabOne = TabItem.withDisplayObject("one", one);
		var tabTwo = TabItem.withDisplayObject("two", two);
		this._navigator.dataProvider = new ArrayCollection([tabOne, tabTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(tabOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
		this._navigator.dataProvider = null;
		this._navigator.validateNow();
		Assert.equals(-1, this._navigator.selectedIndex);
		Assert.isNull(this._navigator.selectedItem);
		Assert.isNull(this._navigator.activeItemView);
	}
}
