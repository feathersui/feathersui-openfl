package feathers.controls.navigators;

import feathers.data.ArrayCollection;
import openfl.Lib;
import openfl.events.Event;
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
		var dispatchedChangeSelectedIndex = -2;
		var dispatchedChangeSelectedItem = {};
		var dispatchedChangeCount = 0;
		this._navigator.addEventListener(Event.CHANGE, function(event:Event):Void {
			dispatchedChangeCount++;
			dispatchedChangeSelectedIndex = this._navigator.selectedIndex;
			dispatchedChangeSelectedItem = this._navigator.selectedItem;
		});

		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
		// Event.CHANGE is dispatched because setting the data provider sets
		// selectedIndex = 0 by default
		Assert.equals(1, dispatchedChangeCount);
		Assert.equals(0, dispatchedChangeSelectedIndex);
		Assert.equals(pageOne, dispatchedChangeSelectedItem);
	}

	public function testSetSelectedIndex():Void {
		var dispatchedChangeSelectedIndex = -2;
		var dispatchedChangeSelectedItem = {};
		var dispatchedChangeCount = 0;
		this._navigator.addEventListener(Event.CHANGE, function(event:Event):Void {
			dispatchedChangeCount++;
			dispatchedChangeSelectedIndex = this._navigator.selectedIndex;
			dispatchedChangeSelectedItem = this._navigator.selectedItem;
		});

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
		// Event.CHANGE doesn't dispatch until validation, so even though
		// setting dataProvider sets selectedIndex = 0, and we also set
		// selectedIndex = 1, there's one dispatch of Event.CHANGE only.
		Assert.equals(1, dispatchedChangeCount);
		Assert.equals(1, dispatchedChangeSelectedIndex);
		Assert.equals(pageTwo, dispatchedChangeSelectedItem);
	}

	public function testSetSelectedItem():Void {
		var dispatchedChangeSelectedIndex = -2;
		var dispatchedChangeSelectedItem = {};
		var dispatchedChangeCount = 0;
		this._navigator.addEventListener(Event.CHANGE, function(event:Event):Void {
			dispatchedChangeCount++;
			dispatchedChangeSelectedIndex = this._navigator.selectedIndex;
			dispatchedChangeSelectedItem = this._navigator.selectedItem;
		});

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
		// Event.CHANGE doesn't dispatch until validation, so even though
		// setting dataProvider sets selectedIndex = 0, and we also set
		// selectedIndex = 1, there's one dispatch of Event.CHANGE only.
		Assert.equals(1, dispatchedChangeCount);
		Assert.equals(1, dispatchedChangeSelectedIndex);
		Assert.equals(pageTwo, dispatchedChangeSelectedItem);
	}

	public function testValidateWithDataProviderThenNoDataProvider():Void {
		var dispatchedChangeSelectedIndex = -2;
		var dispatchedChangeSelectedItem = {};
		var dispatchedChangeCount = 0;
		this._navigator.addEventListener(Event.CHANGE, function(event:Event):Void {
			dispatchedChangeCount++;
			dispatchedChangeSelectedIndex = this._navigator.selectedIndex;
			dispatchedChangeSelectedItem = this._navigator.selectedItem;
		});

		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
		Assert.equals(1, dispatchedChangeCount);
		Assert.equals(0, dispatchedChangeSelectedIndex);
		Assert.equals(pageOne, dispatchedChangeSelectedItem);

		this._navigator.dataProvider = null;
		this._navigator.validateNow();
		Assert.equals(-1, this._navigator.selectedIndex);
		Assert.isNull(this._navigator.selectedItem);
		Assert.isNull(this._navigator.activeItemView);
		Assert.equals(2, dispatchedChangeCount);
		Assert.equals(-1, dispatchedChangeSelectedIndex);
		Assert.isNull(dispatchedChangeSelectedItem);
	}

	public function testValidateWithDataProviderThenNewDataProvider():Void {
		var dispatchedChangeSelectedIndex = -2;
		var dispatchedChangeSelectedItem = {};
		var dispatchedChangeCount = 0;
		this._navigator.addEventListener(Event.CHANGE, function(event:Event):Void {
			dispatchedChangeCount++;
			dispatchedChangeSelectedIndex = this._navigator.selectedIndex;
			dispatchedChangeSelectedItem = this._navigator.selectedItem;
		});

		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageOne, this._navigator.selectedItem);
		Assert.equals(one, this._navigator.activeItemView);
		Assert.equals(1, dispatchedChangeCount);
		Assert.equals(0, dispatchedChangeSelectedIndex);
		Assert.equals(pageOne, dispatchedChangeSelectedItem);

		var three = new LayoutGroup();
		var four = new LayoutGroup();
		var pageThree = PageItem.withDisplayObject(three);
		var pageFour = PageItem.withDisplayObject(four);
		this._navigator.dataProvider = new ArrayCollection([pageThree, pageFour]);
		this._navigator.validateNow();
		Assert.equals(0, this._navigator.selectedIndex);
		Assert.equals(pageThree, this._navigator.selectedItem);
		Assert.equals(three, this._navigator.activeItemView);
		// setting data provider when a view is active clears that view,
		// so there are two changes and not only one
		Assert.equals(3, dispatchedChangeCount);
		Assert.equals(0, dispatchedChangeSelectedIndex);
		Assert.equals(pageThree, dispatchedChangeSelectedItem);
	}

	public function testPageIndicatorDefaultVariant():Void {
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			return pageIndicator;
		}
		this._navigator.validateNow();
		Assert.notNull(pageIndicator);
		Assert.equals(PageNavigator.CHILD_VARIANT_PAGE_INDICATOR, pageIndicator.variant);
	}

	public function testPageIndicatorCustomVariant1():Void {
		final customVariant = "custom";
		this._navigator.customPageIndicatorVariant = customVariant;
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			return pageIndicator;
		}
		this._navigator.validateNow();
		Assert.notNull(pageIndicator);
		Assert.equals(customVariant, pageIndicator.variant);
	}

	public function testPageIndicatorCustomVariant2():Void {
		final customVariant = "custom";
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			pageIndicator.variant = customVariant;
			return pageIndicator;
		}
		this._navigator.validateNow();
		Assert.notNull(pageIndicator);
		Assert.equals(customVariant, pageIndicator.variant);
	}

	public function testPageIndicatorCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._navigator.customPageIndicatorVariant = customVariant1;
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			pageIndicator.variant = customVariant2;
			return pageIndicator;
		}
		this._navigator.validateNow();
		Assert.notNull(pageIndicator);
		Assert.equals(customVariant2, pageIndicator.variant);
	}
}
