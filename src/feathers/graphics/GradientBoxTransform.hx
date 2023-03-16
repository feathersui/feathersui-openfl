/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

/**
	Transformations to apply to `CreateGradientBoxMatrix`.

	@see `feathers.graphics.FillStyle.Gradient`
	@see `feathers.graphics.LineStyle.Gradient`
	@see `feathers.graphics.CreateGradientBoxMatrix`

	@since 1.1.0
**/
enum GradientBoxTransform {
	/**
		Rotates the matrix in radians.

		@since 1.1.0
	**/
	RotateRadians(rotation:Float);

	/**
		Rotates the matrix in degrees.

		@since 1.1.0
	**/
	RotateDegrees(rotation:Float);

	/**
		Translates the matrix.

		@since 1.1.0
	**/
	Translate(tx:Float, ty:Float);

	/**
		Rotates the matrix in radians and translates it.

		@since 1.1.0
	**/
	RotateRadiansAndTranslate(rotation:Float, tx:Float, ty:Float);

	/**
		Rotates the matrix in degrees and translates it.

		@since 1.1.0
	**/
	RotateDegreesAndTranslate(rotation:Float, tx:Float, ty:Float);
}
