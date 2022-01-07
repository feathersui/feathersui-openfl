/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.HorizontalAlign;
import openfl.errors.ArgumentError;

/**
	A skin for Feathers UI components that draws a line vertically from top to
	bottom at the horizontal center position, and filled on the left and right
	sides of the line.

	@since 1.0.0
**/
class VerticalLineSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `VerticalLineSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	/**
		How the line is positioned horizontally (along the x-axis) within the
		skin.

		The following example aligns the line to the left:

		```hx
		skin.verticalAlign = LEFT;
		```

		**Note:** The `HorizontalAlign.JUSTIFY` constant is not supported by this
		component.

		@see `feathers.layout.HorizontalAlign.LEFT`
		@see `feathers.layout.HorizontalAlign.CENTER`
		@see `feathers.layout.HorizontalAlign.RIGHT`

		@since 1.0.0
	**/
	public var horizontalAlign:HorizontalAlign = CENTER;

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
		}

		var positionX = switch (this.horizontalAlign) {
			case LEFT: thicknessOffset;
			case CENTER: this.actualWidth / 2.0;
			case RIGHT: this.actualWidth - thicknessOffset;
			default: throw new ArgumentError("Unknown horizontal align: " + this.horizontalAlign);
		}
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(positionX, minLineY);
		this.graphics.lineTo(positionX, maxLineY);
	}
}
