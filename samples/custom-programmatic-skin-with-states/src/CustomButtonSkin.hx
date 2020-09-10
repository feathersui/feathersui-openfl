import feathers.controls.ButtonState;
import feathers.skins.ProgrammaticSkin;
import openfl.geom.Matrix;

/**
	This skin uses the `stateContext` property from `ProgrammaticSkin` to change
	the appearance of the skin based on the button's current state.
**/
class CustomButtonSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	override private function update():Void {
		this.graphics.clear();

		// the stateContext property may be used to get the current state of the
		// button component.
		var glowColor = switch (this.stateContext.currentState) {
			case ButtonState.DOWN:
				0xffee00;
			default:
				0xffcc00;
		};

		// draw the base shape
		var matrix = new Matrix();
		matrix.createGradientBox(this.actualWidth, this.actualHeight, 0.0, 0.0, this.actualHeight / 2.0);
		// a radial gradient creates a nice internal glow
		this.graphics.beginGradientFill(RADIAL, [glowColor, 0xff9900], [1.0, 1.0], [0x00, 0xff], matrix);
		this.graphics.drawRoundRect(0.0, 0.0, this.actualWidth, this.actualHeight, 20.0);
		this.graphics.endFill();

		var shineAlpha = 0.6;
		if (this.stateContext.currentState == HOVER || this.stateContext.currentState == DOWN) {
			shineAlpha = 0.8;
		}

		// draw the "shine"
		matrix = new Matrix();
		matrix.createGradientBox(this.actualWidth - 12.0, (this.actualHeight - 12.0) / 2.0, Math.PI * 90.0 / 180.0);
		// the linear gradient makes it look like a light is shining from above
		this.graphics.beginGradientFill(LINEAR, [0xffffff, 0xffffff], [shineAlpha, 0.0], [0x00, 0xff], matrix);
		this.graphics.drawRoundRect(6.0, 6.0, this.actualWidth - 12.0, (this.actualHeight - 12.0) / 2.0, 40.0);
		this.graphics.endFill();
	}
}
