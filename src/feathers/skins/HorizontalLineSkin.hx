/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
	public var verticalAlign:VerticalAlign = MIDDLE;

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);

		var positionY = switch (this.verticalAlign) {
			case TOP: thicknessOffset;
			case MIDDLE: this.actualHeight / 2.0;
			case BOTTOM: this.actualHeight - thicknessOffset;
			default: throw new ArgumentError("Unknown vertical align: " + this.verticalAlign);
		}

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(minLineX, positionY);
		this.graphics.lineTo(maxLineX, positionY);
	}
}
