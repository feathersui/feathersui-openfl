/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Constants that define how the fill of the `HProgressBar` and `VProgressBar`
	components is rendered based on the progress bar's value.

	@see `feathers.controls.HProgressBar`
	@see `feathers.controls.VProgressBar`

	@since 1.1.0
**/
enum ProgressBarFillMode {
	/**
		The fill skin is masked, and the mask is resized within the available
		bounds.

		@since 1.1.0
	**/
	MASK;

	/**
		The fill skin is masked, and the mask is resized within the available
		bounds.

		@since 1.1.0
	**/
	SCROLL_RECT;

	/**
		The fill skin is resized within the available bounds.

		@since 1.1.0
	**/
	RESIZE;
}
