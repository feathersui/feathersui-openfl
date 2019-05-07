package feathers.controls.scrolling;

import feathers.core.InvalidationFlag;
import openfl.errors.ArgumentError;

class LayoutViewPort extends LayoutGroup {
	private var _actualMinVisibleWidth:Float = 0;
	private var _explicitMinVisibleWidth:Null<Float> = null;

	public var minVisibleWidth(get, set):Null<Float>;

	private function get_minVisibleWidth():Null<Float> {
		if (this._explicitMinVisibleWidth == null) {
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}

	private function set_minVisibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleWidth == value) {
			return this._explicitMinVisibleWidth;
		}
		var oldValue = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if (value == null) {
			this._actualMinVisibleWidth = 0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleWidth = value;
			if (this._explicitVisibleWidth == null && (this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue)) {
				// only invalidate if this change might affect the visibleWidth
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleWidth;
	}

	public var maxVisibleWidth(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function set_maxVisibleWidth(value:Null<Float>):Null<Float> {
		if (this.maxVisibleWidth == value) {
			return this.maxVisibleWidth;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleWidth cannot be null");
		}
		var oldValue = this.maxVisibleWidth;
		this.maxVisibleWidth = value;
		if (this._explicitVisibleWidth == null && (this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue)) {
			// only invalidate if this change might affect the visibleWidth
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleWidth;
	}

	private var _actualVisibleWidth:Float = 0;
	private var _explicitVisibleWidth:Null<Float> = null;

	public var visibleWidth(get, set):Null<Float>;

	private function get_visibleWidth():Null<Float> {
		if (this._explicitVisibleWidth == null) {
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}

	private function set_visibleWidth(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleWidth == value) {
			return this._explicitVisibleWidth;
		}
		this._explicitVisibleWidth = value;
		if (this._actualVisibleWidth != value) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this._explicitVisibleWidth;
	}

	private var _actualMinVisibleHeight:Float = 0;
	private var _explicitMinVisibleHeight:Null<Float>;

	public var minVisibleHeight(get, set):Null<Float>;

	private function get_minVisibleHeight():Null<Float> {
		if (this._explicitMinVisibleHeight == null) {
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}

	private function set_minVisibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitMinVisibleHeight == value) {
			return this._explicitMinVisibleHeight;
		}
		var oldValue = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if (value == null) {
			this._actualMinVisibleHeight = 0;
			this.setInvalid(InvalidationFlag.SIZE);
		} else {
			this._actualMinVisibleHeight = value;
			if (this._explicitVisibleHeight == null && (this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue)) {
				// only invalidate if this change might affect the visibleHeight
				this.setInvalid(InvalidationFlag.SIZE);
			}
		}
		return this._explicitMinVisibleHeight;
	}

	public var maxVisibleHeight(default, set):Null<Float> = Math.POSITIVE_INFINITY;

	private function get_maxVisibleHeight():Null<Float> {
		return this.maxVisibleHeight;
	}

	private function set_maxVisibleHeight(value:Null<Float>):Null<Float> {
		if (this.maxVisibleHeight == value) {
			return this.maxVisibleHeight;
		}
		if (value == null) {
			throw new ArgumentError("maxVisibleHeight cannot be null");
		}
		var oldValue = this.maxVisibleHeight;
		this.maxVisibleHeight = value;
		if (this._explicitVisibleHeight == null && (this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue)) {
			// only invalidate if this change might affect the visibleHeight
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this.maxVisibleHeight;
	}

	private var _actualVisibleHeight:Float = 0;
	private var _explicitVisibleHeight:Null<Float> = null;

	public var visibleHeight(get, set):Null<Float>;

	private function get_visibleHeight():Null<Float> {
		if (this._explicitVisibleHeight == null) {
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}

	private function set_visibleHeight(value:Null<Float>):Null<Float> {
		if (this._explicitVisibleHeight == value) {
			return this._explicitVisibleHeight;
		}
		this._explicitVisibleHeight = value;
		if (this._actualVisibleHeight != value) {
			this.setInvalid(InvalidationFlag.SIZE);
		}
		return this._explicitVisibleWidth;
	}

	override private function handleLayoutResult():Void {
		var contentWidth = this._layoutResult.contentWidth;
		var contentHeight = this._layoutResult.contentHeight;
		this.saveMeasurements(contentWidth, contentHeight, contentWidth, contentHeight, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this._actualVisibleWidth = viewPortWidth;
		this._actualVisibleHeight = viewPortHeight;
		this._actualMinVisibleWidth = viewPortWidth;
		this._actualMinVisibleHeight = viewPortHeight;
	}
}
