package feathers.controls.navigators;

import feathers.data.ArrayCollection;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class PageNavigatorTest extends Test {
	private var _navigator:PageNavigator;

	public function new() {
		super();
	}

	public function setup():Void {
		this._navigator = new PageNavigator();
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

	public function testNoExceptionOnDoubleDispose():Void {
		this._navigator.validateNow();
		this._navigator.dispose();
		this._navigator.dispose();
		Assert.pass();
	}

	public function testDefaultSelectedIndex():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
	}

	public function testSetSelectedIndex():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.selectedIndex = 1;
		this._navigator.validateNow();
		Assert.equals(1, this._navigator.selectedIndex);
		Assert.equals(pageTwo, this._navigator.selectedItem);
		Assert.equals(two, this._navigator.activeItemView);
	}

	public function testSetSelectedItem():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.selectedItem = pageTwo;
		this._navigator.validateNow();
		Assert.equals(1, this._navigator.selectedIndex);
		Assert.equals(pageTwo, this._navigator.selectedItem);
		Assert.equals(two, this._navigator.activeItemView);
	}

	public function testValidateWithDataProviderThenNoDataProvider():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
		this._navigator.dataProvider = null;
		this._navigator.validateNow();
		Assert.equals(-1, this._navigator.selectedIndex);
		Assert.isNull(this._navigator.selectedItem);
		Assert.isNull(this._navigator.activeItemView);
	}
}
