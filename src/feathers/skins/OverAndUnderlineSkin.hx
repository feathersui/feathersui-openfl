/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;

/**
	A skin for Feathers UI components that draws a border at the top and bottom,
	but not the sides.

	@since 1.0.0
**/
@:deprecated("OverAndUnderlineSkin is deprecated. Replacement: TopAndBottomBorderSkin")
class OverAndUnderlineSkin extends TopAndBottomBorderSkin {
	/**
		Creates a new `OverAndUnderlineSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}
}
