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

	public function testNoExceptionOnDoubleDispose():Void {
		this._navigator.validateNow();
		this._navigator.dispose();
		this._navigator.dispose();
		Assert.pass();
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

	public function testTabBarDefaultVariant():Void {
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			return tabBar;
		}
		this._navigator.validateNow();
		Assert.notNull(tabBar);
		Assert.equals(TabNavigator.CHILD_VARIANT_TAB_BAR, tabBar.variant);
	}

	public function testTabBarCustomVariant1():Void {
		final customVariant = "custom";
		this._navigator.customTabBarVariant = customVariant;
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			return tabBar;
		}
		this._navigator.validateNow();
		Assert.notNull(tabBar);
		Assert.equals(customVariant, tabBar.variant);
	}

	public function testTabBarCustomVariant2():Void {
		final customVariant = "custom";
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			tabBar.variant = customVariant;
			return tabBar;
		}
		this._navigator.validateNow();
		Assert.notNull(tabBar);
		Assert.equals(customVariant, tabBar.variant);
	}

	public function testTabBarCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._navigator.customTabBarVariant = customVariant1;
		var tabBar:TabBar = null;
		this._navigator.tabBarFactory = () -> {
			tabBar = new TabBar();
			tabBar.variant = customVariant2;
			return tabBar;
		}
		this._navigator.validateNow();
		Assert.notNull(tabBar);
		Assert.equals(customVariant2, tabBar.variant);
	}
}
