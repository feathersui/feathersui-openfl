/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.VerticalAlign;
import openfl.errors.ArgumentError;

/**
	A skin for Feathers UI components that draws a line horizontally from left
	to right at the vertical center position, and filled on the top and bottom
	sides of the line.

	@since 1.0.0
**/
class HorizontalLineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `HorizontalLineSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	private var _verticalAlign:VerticalAlign = MIDDLE;

	/**
		How the line is positioned vertically (along the y-axis) within the
		skin.

		The following example aligns the line to the top:

		```haxe
		skin.verticalAlign = TOP;
		```

		**Note:** The `VerticalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.VerticalAlign.TOP`
		@see `feathers.layout.VerticalAlign.MIDDLE`
		@see `feathers.layout.VerticalAlign.BOTTOM`

		@since 1.0.0
	**/
	public var verticalAlign(get, set):VerticalAlign;

	private function get_verticalAlign():VerticalAlign {
		return this._verticalAlign;
	}

	private function set_verticalAlign(value:VerticalAlign):VerticalAlign {
		if (this._verticalAlign == value) {
			return this._verticalAlign;
		}
		this._verticalAlign = value;
		this.setInvalid(STYLES);
		return this._verticalAlign;
	}

	private var _paddingLeft:Float = 0.0;

	/**
		Empty space to the left of the horizontal line.

		@since 1.1.0
	**/
	public var paddingLeft(get, set):Float;

	private function get_paddingLeft():Float {
		return this._paddingLeft;
	}

	private function set_paddingLeft(value:Float):Float {
		if (this._paddingLeft == value) {
			return this._paddingLeft;
		}
		this._paddingLeft = value;
		this.setInvalid(STYLES);
		return this._paddingLeft;
	}

	private var _paddingRight:Float = 0.0;

	/**
		Empty space to the right of the horizontal line.

		@since 1.1.0
	**/
	public var paddingRight(get, set):Float;

	private function get_paddingRight():Float {
		return this._paddingRight;
	}

	private function set_paddingRight(value:Float):Float {
		if (this._paddingRight == value) {
			return this._paddingRight;
		}
		this._paddingRight = value;
		this.setInvalid(STYLES);
		return this._paddingRight;
	}

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset + this._paddingLeft);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset - this._paddingLeft - this._paddingRight);

		var positionY = switch (this._verticalAlign) {
			case TOP: thicknessOffset;
			case MIDDLE: this.actualHeight / 2.0;
			case BOTTOM: this.actualHeight - thicknessOffset;
			default: throw new ArgumentError("Unknown vertical align: " + this._verticalAlign);
		}

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(minLineX, positionY);
		this.graphics.lineTo(maxLineX, positionY);
	}
}
