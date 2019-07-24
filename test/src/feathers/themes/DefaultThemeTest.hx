package feathers.themes;

import massive.munit.Assert;
import feathers.controls.Button;

class DefaultThemeTest {
	private var _control:Button;

	@Before
	public function prepare():Void {
		this._control = new Button();
	}

	@After
	public function cleanup():Void {
		this._control = null;
	}

	@Test
	public function testDefaultThemeStyles():Void {
		this._control.validateNow();
		Assert.isNotNull(this._control.backgroundSkin, "Must have a default style");
	}
}
