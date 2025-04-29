/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.utils.MathUtil;
import utest.Assert;
import utest.Test;

@:keep
class MathUtilTest extends Test {
	public function testRoundToNearest():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundToNearest(a, 0.1));
	}

	public function testRoundToNearest2():Void {
		var a = 0.29999999999;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundToNearest(a, 0.1));
	}

	public function testRoundToNearest3():Void {
		var a = -0.30000000001;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundToNearest(a, 0.1));
	}

	public function testRoundToNearest4():Void {
		var a = -0.29999999999;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundToNearest(a, 0.1));
	}

	public function testRoundToNearest5():Void {
		var a = 123456789;
		Assert.equals(123500000, MathUtil.roundToNearest(a, 100000));
	}

	public function testRoundToNearest6():Void {
		var a = -123456789;
		Assert.equals(-123500000, MathUtil.roundToNearest(a, 100000));
	}

	public function testRoundUpToNearest():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.equals(0.4, MathUtil.roundUpToNearest(a, 0.1));
	}

	public function testRoundUpToNearest2():Void {
		var a = 0.29999999999;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundUpToNearest(a, 0.1));
	}

	public function testRoundUpToNearest3():Void {
		var a = -0.30000000001;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundUpToNearest(a, 0.1));
	}

	public function testRoundUpToNearest4():Void {
		var a = -0.29999999999;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.2, MathUtil.roundUpToNearest(a, 0.1));
	}

	public function testRoundUpToNearest5():Void {
		var a = 123456789;
		Assert.equals(123500000, MathUtil.roundUpToNearest(a, 100000));
	}

	public function testRoundUpToNearest6():Void {
		var a = -123456789;
		Assert.equals(-123400000, MathUtil.roundUpToNearest(a, 100000));
	}

	public function testRoundDownToNearest():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundDownToNearest(a, 0.1));
	}

	public function testRoundDownToNearest2():Void {
		var a = 0.29999999999;
		Assert.notEquals(0.3, a);
		Assert.equals(0.2, MathUtil.roundDownToNearest(a, 0.1));
	}

	public function testRoundDownToNearest3():Void {
		var a = -0.30000000001;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.4, MathUtil.roundDownToNearest(a, 0.1));
	}

	public function testRoundDownToNearest4():Void {
		var a = -0.29999999999;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundDownToNearest(a, 0.1));
	}

	public function testRoundDownToNearest5():Void {
		var a = 123456789;
		Assert.equals(123400000, MathUtil.roundDownToNearest(a, 100000));
	}

	public function testRoundDownToNearest6():Void {
		var a = -123456789;
		Assert.equals(-123500000, MathUtil.roundDownToNearest(a, 100000));
	}

	public function testRoundToPrecision():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundToPrecision(a, 2));
	}

	public function testRoundToPrecision2():Void {
		var a = 0.29999999999;
		Assert.notEquals(0.3, a);
		Assert.equals(0.3, MathUtil.roundToPrecision(a, 2));
	}

	public function testRoundToPrecision3():Void {
		var a = -0.30000000001;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundToPrecision(a, 2));
	}

	public function testRoundToPrecision4():Void {
		var a = -0.29999999999;
		Assert.notEquals(-0.3, a);
		Assert.equals(-0.3, MathUtil.roundToPrecision(a, 2));
	}

	public function testFuzzyEquals():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.isTrue(MathUtil.fuzzyEquals(0.3, a));
	}

	public function testFuzzyEqualsWithMaxDifference():Void {
		var a = 0.30000000001;
		Assert.notEquals(0.3, a);
		Assert.isTrue(MathUtil.fuzzyEquals(0.3, a, 0.0000001));
	}
}
