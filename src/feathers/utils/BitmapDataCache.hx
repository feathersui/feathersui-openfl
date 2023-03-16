/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.BitmapData;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;

/**
	Caches `BitmapData` in memory. Each `BitmapData` object may be saved with
	its own key, such as the URL where the original image file is located.

	@since 1.0.0
**/
class BitmapDataCache {
	/**
		Creates a new `BitmapDataCache` object with the given arguments.

		@since 1.0.0
	**/
	public function new(maxUnretained:Int = 0x7FFFFFFF) {
		this._maxUnretained = maxUnretained;
	}

	private var _unretainedKeys:Array<String> = [];

	private var _unretainedBitmapData:Map<String, BitmapData> = [];

	private var _retainedBitmapData:Map<String, BitmapData> = [];

	private var _retainCounts:Map<String, Int> = [];

	private var _maxUnretained:Int;

	/**
		Limits the number of unretained `BitmapData` objeccts that may be
		stored in memory. The `BitmapData` objects retained least recently will
		be disposed, if there are too many.

		@since 1.0.0
	**/
	public var maxUnretained(get, set):Int;

	private function get_maxUnretained():Int {
		return this._maxUnretained;
	}

	private function set_maxUnretained(value:Int):Int {
		if (this._maxUnretained == value) {
			return this._maxUnretained;
		}
		this._maxUnretained = value;
		if (this._unretainedKeys.length > value) {
			this.trimCache();
		}
		return this._maxUnretained;
	}

	/**
		Disposes the `BitmapData` cache, including all `BitmapData` objects
		(even if they are retained, so be careful!).

		@since 1.0.0
	**/
	public function dispose():Void {
		for (bitmapData in this._unretainedBitmapData) {
			bitmapData.dispose();
		}
		for (bitmapData in this._retainedBitmapData) {
			bitmapData.dispose();
		}
		this._retainedBitmapData = null;
		this._unretainedBitmapData = null;
		this._retainCounts = null;
	}

	/**
		Saves a `BitmapData` object, and associates it with a specific key.

		@see `BitmapDataCache.removeBitmapData()`
		@see `BitmapDataCache.hasBitmapData()`

		@since 1.0.0
	**/
	public function addBitmapData(key:String, bitmapData:BitmapData, retain:Bool = true):Void {
		if (this._retainedBitmapData == null) {
			throw new IllegalOperationError("Cannot add BitmapData after the cache has been disposed.");
		}
		if (this._unretainedBitmapData.exists(key) || this._retainedBitmapData.exists(key)) {
			throw new ArgumentError('Key "$key" already exists in the cache.');
		}
		if (retain) {
			this._retainedBitmapData.set(key, bitmapData);
			this._retainCounts.set(key, 1);
			return;
		}
		this._unretainedBitmapData.set(key, bitmapData);
		this._unretainedKeys[this._unretainedKeys.length] = key;
		if (this._unretainedKeys.length > this._maxUnretained) {
			this.trimCache();
		}
	}

	/**
		Removes a specific key from the cache, and optionally disposes the
		`BitmapData` object associated with the key.

		@see `BitmapDataCache.addBitmapData()`

		@since 1.0.0
	**/
	public function removeBitmapData(key:String, dispose:Bool = false):Void {
		if (this._unretainedBitmapData == null) {
			return;
		}
		var bitmapData = this._unretainedBitmapData.get(key);
		if (bitmapData != null) {
			this.removeUnretainedKey(key);
		} else {
			bitmapData = this._retainedBitmapData.get(key);
			this._retainedBitmapData.remove(key);
			this._retainCounts.remove(key);
		}
		if (dispose && bitmapData != null) {
			bitmapData.dispose();
		}
	}

	/**
		Indicates if a `BitmapData` object is associated with the specified key.

		@since 1.0.0
	**/
	public function hasTexture(key:String):Bool {
		return (this._retainedBitmapData != null && this._retainedBitmapData.exists(key))
			|| (this._unretainedBitmapData != null && this._unretainedBitmapData.exists(key));
	}

	/**
		Returns how many times the `BitmapData` object associated with the
		specified key has currently been retained.

		@since 1.0.0
	**/
	public function getRetainCount(key:String):Int {
		if (this._retainCounts != null && this._retainCounts.exists(key)) {
			return this._retainCounts.get(key);
		}
		return 0;
	}

	/**
		Gets the `BitmapData` object associated with the specified key, and
		increments the retain count for the `BitmapData` object. Always remember
		to call `releaseBitmapData()` when finished with a retained `BitmapData`
		object.

		@see `BitmapDataCache.releaseBitmapData()`

		@since 1.0.0
	**/
	public function retainBitmapData(key:String):BitmapData {
		if (this._retainedBitmapData == null) {
			throw new IllegalOperationError("Cannot retain BitmapData after the cache has been disposed.");
		}
		if (this._retainedBitmapData.exists(key)) {
			var count = this._retainCounts.get(key);
			count++;
			this._retainCounts.set(key, count);
			return this._retainedBitmapData.get(key);
		}

		if (!this._unretainedBitmapData.exists(key)) {
			throw new ArgumentError('BitmapData with key "$key" cannot be retained because it has not been added to the cache.');
		}
		var bitmapData = this._unretainedBitmapData.get(key);
		this.removeUnretainedKey(key);
		this._retainedBitmapData.set(key, bitmapData);
		this._retainCounts.set(key, 1);
		return bitmapData;
	}

	/**
		Releases a retained `BitmapData` object.

		@see `BitmapDataCache.retainBitmapData()`

		@since 1.0.0
	**/
	public function releaseBitmapData(key:String):Void {
		if (this._retainedBitmapData == null || !this._retainedBitmapData.exists(key)) {
			return;
		}
		var count = this._retainCounts.get(key);
		count--;
		if (count == 0) {
			// get the existing bitmap data
			var bitmapData = this._retainedBitmapData.get(key);

			// remove from retained
			this._retainCounts.remove(key);
			this._retainedBitmapData.remove(key);

			this._unretainedBitmapData.set(key, bitmapData);
			this._unretainedKeys[this._unretainedKeys.length] = key;
			if (this._unretainedKeys.length > this._maxUnretained) {
				this.trimCache();
			}
		} else {
			this._retainCounts.set(key, count);
		}
	}

	private function removeUnretainedKey(key:String):Void {
		var index = this._unretainedKeys.indexOf(key);
		if (index == -1) {
			return;
		}
		this._unretainedKeys.splice(index, 1);
		this._unretainedBitmapData.remove(key);
	}

	private function trimCache():Void {
		var currentCount = this._unretainedKeys.length;
		var maxCount = this._maxUnretained;
		while (currentCount > maxCount) {
			var key:String = this._unretainedKeys.shift();
			var bitmapData = this._unretainedBitmapData.get(key);
			bitmapData.dispose();
			this._unretainedBitmapData.remove(key);
			currentCount--;
		}
	}
}
