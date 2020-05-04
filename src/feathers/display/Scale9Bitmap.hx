/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.display;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import openfl.display.Shape;
import openfl.display.BitmapData;

/**
	Renders `BitmapData` in nine slices using the `scale9Grid` property.

	The following example creates a bitmap with `scale9Grid`.

	```hx
	var bitmap = new Scale9Bitmap(Assets.getBitmapData("myBitmap"), new Rectangle(4.0, 4.0, 16.0, 8.0));
	```

	@since 1.0.0
**/
class Scale9Bitmap extends Shape {
	/**
		Creates a new `Scale9Bitmap` object with the given arguments.

		@since 1.0.0
	**/
	public function new(bitmapData:BitmapData, scale9Grid:Rectangle, smoothing:Bool = false) {
		super();
		this._allowRefresh = false;
		this.bitmapData = bitmapData;
		this.scale9Grid = scale9Grid;
		this._width = this.bitmapData.width;
		this._height = this.bitmapData.height;
		this.smoothing = smoothing;
		this._allowRefresh = true;
		this.refreshSubBitmapData();
		this.draw();
	}

	private var _allowRefresh = true;

	private var topLeft:BitmapData;
	private var topCenter:BitmapData;
	private var topRight:BitmapData;
	private var middleLeft:BitmapData;
	private var middleCenter:BitmapData;
	private var middleRight:BitmapData;
	private var bottomLeft:BitmapData;
	private var bottomCenter:BitmapData;
	private var bottomRight:BitmapData;

	private var top:Int = 0;
	private var right:Int = 0;
	private var bottom:Int = 0;
	private var left:Int = 0;
	private var center:Int = 0;
	private var middle:Int = 0;

	private var _width:Float = 0.0;

	@:getter(width)
	#if !flash override #end private function get_width():Float {
		return this._width;
	}

	@:setter(width)
	#if !flash override #end private function set_width(value:Float):#if !flash Float #else Void #end {
		if (this._width == value) {
			return #if !flash this._width #end;
		}
		this._width = value;
		if (this._allowRefresh) {
			this.draw();
		}
		#if !flash
		return this._width;
		#end
	}

	private var _height:Float = 0.0;

	@:getter(height)
	#if !flash override #end private function get_height():Float {
		return this._height;
	}

	@:setter(height)
	#if !flash override #end private function set_height(value:Float):#if !flash Float #else Void #end {
		if (this._height == value) {
			return #if !flash this._height #end;
		}
		this._height = value;
		if (this._allowRefresh) {
			this.draw();
		}
		#if !flash
		return this._height;
		#end
	}

	/**
		Controls whether or not the bitmap is smoothed when scaled.

		@see `openfl.display.Bitmap.smoothing`

		@since 1.0.0
	**/
	public var smoothing(default, set):Bool = false;

	private function set_smoothing(value:Bool):Bool {
		if (this.smoothing == value) {
			return this.smoothing;
		}
		this.smoothing = value;
		if (this._allowRefresh) {
			this.draw();
		}
		return this.smoothing;
	}

	/**
		The `BitmapData` object being referenced.

		@see `openfl.display.Bitmap.bitmapData`

		@since 1.0.0
	**/
	public var bitmapData(default, set):BitmapData;

	private function set_bitmapData(value:BitmapData):BitmapData {
		if (this.bitmapData == value) {
			return this.bitmapData;
		}
		this.bitmapData = value;
		if (this.bitmapData == null) {
			throw new ArgumentError("Invalid BitmapData");
		}
		if (this._allowRefresh) {
			this.refreshSubBitmapData();
			this.draw();
		}
		return this.bitmapData;
	}

	private var _scale9Grid:Rectangle;

	@:getter(scale9Grid)
	#if !flash override #end private function get_scale9Grid():Rectangle {
		return this._scale9Grid;
	}

	@:setter(scale9Grid)
	#if !flash override #end private function set_scale9Grid(value:Rectangle):#if !flash Rectangle #else Void #end {
		if (this._scale9Grid == value || (this._scale9Grid != null && this._scale9Grid.equals(value))) {
			return #if !flash this._scale9Grid #end;
		}
		this._scale9Grid = value;
		if (this._allowRefresh) {
			this.refreshSubBitmapData();
			this.draw();
		}
		#if !flash
		return this._scale9Grid;
		#end
	}

	private var _matrix = new Matrix();
	private var _point = new Point();
	private var _rectangle = new Rectangle();

	private function refreshSubBitmapData():Void {
		if (this.topLeft != null) {
			this.topLeft.dispose();
			this.topLeft = null;
		}
		if (this.topCenter != null) {
			this.topCenter.dispose();
			this.topCenter = null;
		}
		if (this.topRight != null) {
			this.topRight.dispose();
			this.topRight = null;
		}
		if (this.middleLeft != null) {
			this.middleLeft.dispose();
			this.middleLeft = null;
		}
		if (this.middleCenter != null) {
			this.middleCenter.dispose();
			this.middleCenter = null;
		}
		if (this.middleRight != null) {
			this.middleRight.dispose();
			this.middleRight = null;
		}
		if (this.bottomLeft != null) {
			this.bottomLeft.dispose();
			this.bottomLeft = null;
		}
		if (this.bottomCenter != null) {
			this.bottomCenter.dispose();
			this.bottomCenter = null;
		}
		if (this.bottomRight != null) {
			this.bottomRight.dispose();
			this.bottomRight = null;
		}
		if (this._scale9Grid == null) {
			return;
		}

		this.left = Std.int(Math.max(0.0, this._scale9Grid.x));
		this.top = Std.int(Math.max(0.0, this._scale9Grid.y));
		this.center = Std.int(Math.max(0.0, this._scale9Grid.width));
		this.middle = Std.int(Math.max(0.0, this._scale9Grid.height));
		this.right = Std.int(Math.max(0.0, this.bitmapData.width - this.left - this.center));
		this.bottom = Std.int(Math.max(0.0, this.bitmapData.height - this.top - this.middle));

		this._point.setTo(0.0, 0.0);

		this.topLeft = new BitmapData(this.left, this.top);
		this._rectangle.setTo(0.0, 0.0, this.topLeft.width, this.topLeft.height);
		this.topLeft.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.topCenter = new BitmapData(this.center, this.top);
		this._rectangle.setTo(this.left, 0.0, this.topCenter.width, this.topCenter.height);
		this.topCenter.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.topRight = new BitmapData(this.right, this.top);
		this._rectangle.setTo(this.left + this.center, 0.0, this.topRight.width, this.topRight.height);
		this.topRight.copyPixels(this.bitmapData, this._rectangle, this._point);

		this.middleLeft = new BitmapData(this.left, this.middle);
		this._rectangle.setTo(0.0, this.top, this.middleLeft.width, this.middleLeft.height);
		this.middleLeft.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.middleCenter = new BitmapData(this.center, this.middle);
		this._rectangle.setTo(this.left, this.top, this.middleCenter.width, this.middleCenter.height);
		this.middleCenter.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.middleRight = new BitmapData(this.right, this.middle);
		this._rectangle.setTo(this.left + this.center, this.top, this.middleRight.width, this.middleRight.height);
		this.middleRight.copyPixels(this.bitmapData, this._rectangle, this._point);

		this.bottomLeft = new BitmapData(this.top, this.bottom);
		this._rectangle.setTo(0.0, this.top + this.middle, this.bottomLeft.width, this.bottomLeft.height);
		this.bottomLeft.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.bottomCenter = new BitmapData(this.center, this.bottom);
		this._rectangle.setTo(this.left, this.top + this.middle, this.bottomCenter.width, this.bottomCenter.height);
		this.bottomCenter.copyPixels(this.bitmapData, this._rectangle, this._point);
		this.bottomRight = new BitmapData(this.right, this.bottom);
		this._rectangle.setTo(this.left + this.center, this.top + this.middle, this.bottomRight.width, this.bottomRight.height);
		this.bottomRight.copyPixels(this.bitmapData, this._rectangle, this._point);
	}

	private function draw():Void {
		this.graphics.clear();
		if (this._width == 0 || this._height == 0) {
			// nothing to draw
			return;
		}

		if (this._scale9Grid == null) {
			this._matrix.identity();
			this._matrix.scale(this._width / this.bitmapData.width, this._height / this.bitmapData.height);
			this.graphics.beginBitmapFill(this.bitmapData, this._matrix, false, this.smoothing);
			this.graphics.drawRect(0.0, 0.0, this._width, this._height);
			this.graphics.endFill();
			return;
		}

		var center2 = Math.max(0.0, this._width - left - right);
		var middle2 = Math.max(0.0, this._height - top - bottom);

		//--- top row

		if (this.topLeft != null) {
			this._matrix.identity();
			this.graphics.beginBitmapFill(this.topLeft, null, false, this.smoothing);
			this.graphics.drawRect(0.0, 0.0, left, top);
			this.graphics.endFill();
		}
		if (this.topCenter != null) {
			this._matrix.identity();
			this._matrix.scale(center2 / center, 1.0);
			this._matrix.translate(left, 0.0);
			this.graphics.beginBitmapFill(this.topCenter, this._matrix, false, this.smoothing);
			this.graphics.drawRect(left, 0.0, center2, top);
			this.graphics.endFill();
		}
		if (this.topRight != null) {
			this._matrix.identity();
			this._matrix.translate(this._width - right, 0.0);
			this.graphics.beginBitmapFill(this.topRight, this._matrix, false, this.smoothing);
			this.graphics.drawRect(this._width - right, 0.0, right, top);
			this.graphics.endFill();
		}

		//--- middle row

		if (this.middleLeft != null) {
			this._matrix.identity();
			this._matrix.scale(1.0, middle2 / middle);
			this._matrix.translate(0.0, top);
			this.graphics.beginBitmapFill(this.middleLeft, this._matrix, false, this.smoothing);
			this.graphics.drawRect(0.0, top, left, middle2);
			this.graphics.endFill();
		}
		if (this.middleCenter != null) {
			this._matrix.identity();
			this._matrix.scale(center2 / center, middle2 / middle);
			this._matrix.translate(left, top);
			this.graphics.beginBitmapFill(this.middleCenter, this._matrix, false, this.smoothing);
			this.graphics.drawRect(left, top, center2, middle2);
			this.graphics.endFill();
		}
		if (this.middleRight != null) {
			this._matrix.identity();
			this._matrix.scale(1.0, middle2 / middle);
			this._matrix.translate(this._width - right, top);
			this.graphics.beginBitmapFill(this.middleRight, this._matrix, false, this.smoothing);
			this.graphics.drawRect(this._width - right, top, right, middle2);
			this.graphics.endFill();
		}

		//--- bottom row

		if (this.bottomLeft != null) {
			this._matrix.identity();
			this._matrix.translate(0.0, this._height - bottom);
			this.graphics.beginBitmapFill(this.bottomLeft, this._matrix, false, this.smoothing);
			this.graphics.drawRect(0.0, this._height - bottom, left, bottom);
			this.graphics.endFill();
		}
		if (this.bottomCenter != null) {
			this._matrix.identity();
			this._matrix.scale(center2 / center, 1.0);
			this._matrix.translate(left, this._height - bottom);
			this.graphics.beginBitmapFill(this.bottomCenter, this._matrix, false, this.smoothing);
			this.graphics.drawRect(left, this._height - bottom, center2, bottom);
			this.graphics.endFill();
		}
		if (this.bottomRight != null) {
			this._matrix.identity();
			this._matrix.translate(this._width - right, this._height - bottom);
			this.graphics.beginBitmapFill(this.bottomRight, this._matrix, false, this.smoothing);
			this.graphics.drawRect(this._width - right, this._height - bottom, right, bottom);
			this.graphics.endFill();
		}
	}
}
