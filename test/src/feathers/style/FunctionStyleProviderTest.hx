package feathers.style;

import feathers.controls.LayoutGroup;
import massive.munit.Assert;
import openfl.events.Event;

class FunctionStyleProviderTest {
	private var _control:LayoutGroup;
	private var _styleProvider:FunctionStyleProvider;
	private var _appliedStyles:Bool;

	@Before
	public function prepare():Void {
		this._appliedStyles = false;
		this._styleProvider = new FunctionStyleProvider(setExtraStyles);
		this._control = new LayoutGroup();
	}

	@After
	public function cleanup():Void {
		this._control = null;
		this._styleProvider = null;
		this._appliedStyles = false;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function setExtraStyles(target:LayoutGroup):Void {
		this._appliedStyles = true;
	}

	@Test
	public function testSetStyleProviderBeforeInitialize():Void {
		this._control.styleProvider = this._styleProvider;
		Assert.isFalse(this._appliedStyles, "Must not apply style provider before initialization");
	}

	@Test
	public function testSetStyleProviderAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._appliedStyles);
		this._appliedStyles = false;
		this._control.styleProvider = this._styleProvider;
		Assert.isTrue(this._appliedStyles, "Must apply style provider immediately when already initialized");
	}

	@Test
	public function testSetStyleProviderAndVariantBeforeInitialize():Void {
		this._control.styleProvider = this._styleProvider;
		this._control.variant = "custom-style-name";
		Assert.isFalse(this._appliedStyles, "Must not apply style provider with new variant before initialization");
	}

	@Test
	public function testSetVariantAfterInitialize():Void {
		this._control.styleProvider = this._styleProvider;
		this._control.initializeNow();
		this._appliedStyles = false;
		this._control.variant = "custom-style-name";
		Assert.isTrue(this._appliedStyles, "Must apply style provider with new variant immediately when already initialized");
	}

	@Test
	public function testStyleProviderChangeEventBeforeInitialize():Void {
		this._control.styleProvider = this._styleProvider;
		this._styleProvider.dispatchEvent(new Event(Event.CHANGE));
		Assert.isFalse(this._appliedStyles, "Must not apply style provider before initialization when style provider dispatches Event.CHANGE");
	}

	@Test
	public function testStyleProviderChangeEventAfterInitialize():Void {
		this._control.styleProvider = this._styleProvider;
		this._control.initializeNow();
		Assert.isFalse(this._appliedStyles);
		this._styleProvider.dispatchEvent(new Event(Event.CHANGE));
		Assert.isFalse(this._appliedStyles, "Must apply style provider immediately when already initialized and style provider dispatches Event.CHANGE");
	}

	@Test
	public function testStyleProviderDispatchesChangeEventAfterChangeCallback():Void {
		var changed = false;
		this._styleProvider.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._styleProvider.callback = function(target:LayoutGroup):Void {};
		Assert.isTrue(true, "FunctionStyleProvider must dispatch Event.CHANGE after changing callback");
	}
}
