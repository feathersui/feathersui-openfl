package feathers.core;

import openfl.display.Sprite;
import feathers.controls.LayoutGroup;
import massive.munit.Assert;

@:access(feathers.core.FeathersControl)
class RestrictedStyleTest {
	private var _control:LayoutGroup;

	@Before
	public function prepare():Void {
		this._control = new LayoutGroup();
	}

	@After
	public function cleanup():Void {
		this._control = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testStyleNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after constructor.");
	}

	@Test
	public function testStyleNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after validate.");
	}

	@Test
	public function testStyleNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after validate.");
	}

	@Test
	public function testRestrictedStyle():Void {
		this._control.backgroundSkin = new Sprite();
		Assert.isTrue(this._control.isStyleRestricted("backgroundSkin"), "Setting style property must restrict it.");
	}
}
