/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.graphics;

import openfl.errors.ArgumentError;
import openfl.geom.Matrix;

/**
	A callback that creates an `openfl.geom.Matrix` and calls
	`createGradientBox()` with the specified arguments.

	@see `feathers.graphics.FillStyle.Gradient`
	@see `feathers.graphics.LineStyle.Gradient`

	@since 1.0.0
**/
abstract CreateGradientBoxMatrix((Float, Float, ?Float, ?Float,
		?Float) -> Matrix) from (Float, Float, ?Float, ?Float, ?Float) -> Matrix to (Float, Float, ?Float, ?Float, ?Float) -> Matrix {
	@:from
	public static function fromGradientBoxTransform(transform:GradientBoxTransform):CreateGradientBoxMatrix {
		switch (transform) {
			case RotateRadians(rotation):
				return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
					var matrix = new Matrix();
					matrix.createGradientBox(defaultWidth, defaultHeight, rotation, defaultTx, defaultTy);
					return matrix;
				}
			case RotateDegrees(rotation):
				return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
					var matrix = new Matrix();
					matrix.createGradientBox(defaultWidth, defaultHeight, rotation * Math.PI / 180.0, defaultTx, defaultTy);
					return matrix;
				}
			case Translate(tx, ty):
				return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
					var matrix = new Matrix();
					matrix.createGradientBox(defaultWidth, defaultHeight, defaultRadians, tx, ty);
					return matrix;
				}
			case RotateRadiansAndTranslate(rotation, tx, ty):
				return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
					var matrix = new Matrix();
					matrix.createGradientBox(defaultWidth, defaultHeight, rotation, tx, ty);
					return matrix;
				}
			case RotateDegreesAndTranslate(rotation, tx, ty):
				return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
					var matrix = new Matrix();
					matrix.createGradientBox(defaultWidth, defaultHeight, rotation * Math.PI / 180.0, tx, ty);
					return matrix;
				}
			default:
				throw new ArgumentError("Unknown GradientBoxTransform: " + transform);
		}
	}

	/**
		Converts a `Float` value, measured in radians, to a `CreateGradientBoxMatrix` callback.

		@since 1.0.0
	**/
	@:from
	public static function fromRadians(radians:Float):CreateGradientBoxMatrix {
		return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
			var matrix = new Matrix();
			matrix.createGradientBox(defaultWidth, defaultHeight, radians, defaultTx, defaultTy);
			return matrix;
		}
	}

	/**
		Converts an `openfl.geom.Matrix` value a `CreateGradientBoxMatrix` callback.

		@since 1.0.0
	**/
	@:from
	public static function fromMatrix(matrix:Matrix):CreateGradientBoxMatrix {
		return (defaultWidth:Float, defaultHeight:Float, ?defaultRadians:Float, ?defaultTx:Float, ?defaultTy:Float) -> {
			return matrix;
		}
	}
}
