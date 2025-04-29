package feathers.utils;

/**
	Utility functions for mathematical calculations.

	@since 1.0.0
**/
class MathUtil {
	/**
		Rounds a number *down* to the nearest multiple of an input. For example,
		by rounding `16` down to the nearest `10`, you will receive `10`, and by
		rounding `26` down to the nearest `10`, you will receive `20`. Similar
		to the built-in function `Math.floor()`.

		@param	numberToRound		the number to round down
		@param	nearest				the number whose mutiple must be found
		@return	the rounded number

		@see `Math.floor`
		@see `Math.ffloor`

		@since 1.0.0
	**/
	public static function roundDownToNearest(number:Float, nearest:Float = 1.0):Float {
		if (nearest == 0.0) {
			return number;
		}
		if (nearest > -1.0 && nearest < 1.0) {
			// this seems to be more accurate for nearest fractions
			var multiplier = 1.0 / nearest;
			return Math.ffloor(multiplier * number) / multiplier;
		}
		return Math.ffloor(MathUtil.roundToPrecision(number / nearest, 10)) * nearest;
	}

	/**
		Rounds a number *up* to the nearest multiple of an input. For example,
		by rounding `16` up to the nearest `10`, you will receive `20`, and by
		rounding `26` up to the nearest `10`, you will receive `30`. Similar
		to the built-in function `Math.ceil()`.

		@param	numberToRound		the number to round up
		@param	nearest				the number whose mutiple must be found
		@return	the rounded number

		@see `Math.ceil`
		@see `Math.fceil`

		@since 1.0.0
	**/
	public static function roundUpToNearest(number:Float, nearest:Float = 1.0):Float {
		if (nearest == 0.0) {
			return number;
		}
		if (nearest > -1.0 && nearest < 1.0) {
			// this seems to be more accurate for nearest fractions
			var multiplier = 1.0 / nearest;
			return Math.fceil(multiplier * number) / multiplier;
		}
		return Math.fceil(MathUtil.roundToPrecision(number / nearest, 10)) * nearest;
	}

	/**
		Rounds a number to the nearest multiple of an input. For example,
		by rounding `26` to the nearest `10`, you will receive `30`, and by
		rounding `24` to the nearest `10`, you will receive `20`. Similar
		to the built-in function `Math.round()`.

		@param	numberToRound		the number to round
		@param	nearest				the number whose mutiple must be found
		@return	the rounded number

		@see `Math.round`
		@see `Math.fround`

		@since 1.0.0
	**/
	public static function roundToNearest(number:Float, nearest:Float = 1.0):Float {
		if (nearest == 0.0) {
			return number;
		}
		if (nearest > -1.0 && nearest < 1.0) {
			// this seems to be more accurate for nearest fractions
			var multiplier = 1.0 / nearest;
			return Math.fround(multiplier * number) / multiplier;
		}
		return Math.fround(MathUtil.roundToPrecision(number / nearest, 10)) * nearest;
	}

	/**
		Rounds a number to a certain level of decimal precision. Useful for
		limiting the number of decimal places on a fractional number.

		@param		number		the input number to round.
		@param		precision	the number of decimal digits to keep
		@return		the rounded number, or the original input if no rounding is needed

		@since 1.0.0
	**/
	public static function roundToPrecision(number:Float, precision:Int = 0):Float {
		var decimalPlaces = Math.pow(10, precision);
		return Math.fround(decimalPlaces * number) / decimalPlaces;
	}

	/**
		Compares two `Float` values in a way that they are considered equal if
		their difference is below a certain threshold. Useful for meaningful
		comparisons between numbers that may be slightly different due to
		floating point errors.

		@param		n1				the first number to compare
		@param		n2				the second number to compare
		@param		maxDifference	the maximum difference between the two numbers to be considered equal
		@return		true if the numbers are considered equal
	**/
	public static function fuzzyEquals(n1:Float, n2:Float, maxDifference:Float = 0.000001):Bool {
		return Math.abs(n1 - n2) <= maxDifference;
	}
}
