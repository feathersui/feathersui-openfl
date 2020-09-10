import openfl.geom.Matrix;
import feathers.skins.ProgrammaticSkin;

/**
	Extend the `ProgrammaticSkin` class to draw your own custom graphics to use
	as a skin for a Feathers UI component.
**/
class CustomSkin extends ProgrammaticSkin {
	public function new() {
		super();
	}

	/**
		Create an override of the `update()` method to draw your graphics.
	**/
	override private function update():Void {
		// always clear before re-drawing
		this.graphics.clear();
		this.graphics.lineStyle(10.0, 0xff6666);
		this.graphics.beginFill(0xffcccc);
		this.graphics.moveTo(20.0, 5.0);
		this.graphics.lineTo(this.actualWidth - 20.0, 5.0);
		this.graphics.curveTo(this.actualWidth - 20.0, 20.0, this.actualWidth - 5.0, 20.0);
		this.graphics.lineTo(this.actualWidth - 5.0, this.actualHeight - 20.0);
		this.graphics.curveTo(this.actualWidth - 20.0, this.actualHeight - 20.0, this.actualWidth - 20.0, this.actualHeight - 5.0);
		this.graphics.lineTo(20.0, this.actualHeight - 5.0);
		this.graphics.curveTo(20.0, this.actualHeight - 20.0, 5.0, this.actualHeight - 20.0);
		this.graphics.lineTo(5.0, 20.0);
		this.graphics.curveTo(20.0, 20.0, 20.0, 5.0);
	}
}
