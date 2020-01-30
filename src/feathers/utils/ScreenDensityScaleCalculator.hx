/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.errors.IllegalOperationError;
import openfl.errors.ArgumentError;

/**
	Selects a scale value for the application based on the screen density
	(sometimes density is called DPI or PPI).

	@see [`openfl.system.Capabilities.screenDPI`](https://api.openfl.org/openfl/system/Capabilities.html#screenDPI)

	@since 1.0.0
**/
class ScreenDensityScaleCalculator {
	/**
		Creates a new `ScreenDensityScaleCalculator` object.

		@since 1.0.0
	**/
	public function new() {}

	private var _buckets:Array<ScreenDensityBucket> = [];

	/**
		Adds a new scale for the specified screen density.

		```hx
		calculator.addScaleForDensity(160, 1);
		calculator.addScaleForDensity(240, 1.5);
		calculator.addScaleForDensity(320, 2);
		calculator.addScaleForDensity(480, 3);
		```
	**/
	public function addScaleForDensity(density:Float, scale:Float):Void {
		var i = this._buckets.length;
		for (bucket in this._buckets) {
			if (bucket.density > density) {
				break;
			}
			if (bucket.density == density) {
				throw new ArgumentError("Screen density cannot be added more than once: " + density);
			}
		}
		this._buckets.insert(i, new ScreenDensityBucket(density, scale));
	}

	/**
		Removes an application scale that was added with `addScaleForDensity()`.

		```hx
		selector.addScaleForDensity(320, 2);
		selector.removeScaleForDensity(320);
		```

		@see `ScreenDensityScaleCalculator.addScaleForDensity()`
	**/
	public function removeScaleForDensity(density:Float):Void {
		for (bucket in this._buckets) {
			if (bucket.density == density) {
				this._buckets.remove(bucket);
				return;
			}
		}
	}

	/**
		Returns the ideal scale for the specified screen density.
	**/
	public function getScale(density:Float):Float {
		if (this._buckets.length == 0) {
			throw new IllegalOperationError("Cannot choose scale because none have been added");
		}
		var bucket = this._buckets[0];
		if (density <= bucket.density) {
			return bucket.scale;
		}
		var previousBucket = bucket;
		for (i in 1...this._buckets.length) {
			bucket = this._buckets[i];
			if (density > bucket.density) {
				previousBucket = bucket;
				continue;
			}
			var midDPI = (bucket.density + previousBucket.density) / 2.0;
			if (density < midDPI) {
				return previousBucket.scale;
			}
			return bucket.scale;
		}
		return bucket.scale;
	}
}

private class ScreenDensityBucket {
	public function new(density:Float, scale:Float) {
		this.density = density;
		this.scale = scale;
	}

	public var density:Float;
	public var scale:Float;
}
