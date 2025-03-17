/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

/**
	A skin that indicates that an activity of indeterminate length is currently
	happening. The skin's `indeterminatePosition` property may be used to
	animate its appearance over time.

	@since 1.1.0

	@see `feathers.controls.ActivityIndicator`
**/
interface IIndeterminateSkin extends IProgrammaticSkin {
	/**
		Set to a value in the range between `0.0` and `1.0` over time to animate
		the skin's appearance.

		@since 1.1.0
	**/
	var indeterminatePosition(get, set):Float;
}
