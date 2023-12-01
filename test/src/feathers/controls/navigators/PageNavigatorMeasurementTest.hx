package feathers.controls.navigators;

import feathers.data.ArrayCollection;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class PageNavigatorMeasurementTest extends Test {
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

	public function testDimensionsAutoSizeStage():Void {
		var one = new LayoutGroup();
		var two = new LayoutGroup();
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.autoSizeMode = STAGE;
		this._navigator.pageIndicatorPosition = TOP;
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
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.autoSizeMode = CONTENT;
		this._navigator.gap = GAP;
		this._navigator.pageIndicatorPosition = TOP;
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			return pageIndicator;
		}

		this._navigator.validateNow();
		Assert.isTrue(pageIndicator.width > 0.0);
		Assert.isTrue(pageIndicator.height > 0.0);
		Assert.equals(pageIndicator.width, this._navigator.width);
		Assert.equals(pageIndicator.height + GAP + one.height, this._navigator.height);
	}

	public function testDimensionsAutoSizeContentLargerContentWidth():Void {
		final GAP = 10.0;
		var one = new LayoutGroup();
		one.width = 1000.0;
		one.height = 100.0;
		var two = new LayoutGroup();
		two.width = 1000.0;
		two.height = 150.0;
		var pageOne = PageItem.withDisplayObject(one);
		var pageTwo = PageItem.withDisplayObject(two);
		this._navigator.dataProvider = new ArrayCollection([pageOne, pageTwo]);
		this._navigator.autoSizeMode = CONTENT;
		this._navigator.gap = GAP;
		this._navigator.pageIndicatorPosition = TOP;
		var pageIndicator:PageIndicator = null;
		this._navigator.pageIndicatorFactory = () -> {
			pageIndicator = new PageIndicator();
			return pageIndicator;
		}

		this._navigator.validateNow();
		Assert.isTrue(pageIndicator.width > 0.0);
		Assert.isTrue(pageIndicator.height > 0.0);
		Assert.equals(one.width, this._navigator.width);
		Assert.equals(pageIndicator.height + GAP + one.height, this._navigator.height);
	}
}
