/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.display;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
	Renders `BitmapData` in nine slices using the `scale9Grid` property.

	The following example creates a bitmap with `scale9Grid`.

	```haxe
	var bitmap = new Scale9Bitmap(Assets.getBitmapData("myBitmap"), new Rectangle(4.0, 4.0, 16.0, 8.0));
	```

	@since 1.0.0
**/
class Scale9Bitmap extends Sprite {
	/**
		Creates a new `Scale9Bitmap` object with the given arguments.

		@since 1.0.0
	**/
	public function new(bitmapData:BitmapData, scale9Grid:Rectangle, smoothing:Bool = false) {
		super();
		this._allowRefresh = false;
		this.bitmapData = bitmapData;
		this.scale9Grid = scale9Grid;
		this._width = this._bitmapData.width;
		this._height = this._bitmapData.height;
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

	private var _topLeftBitmap:Bitmap;
	private var _topCenterBitmap:Bitmap;
	private var _topRightBitmap:Bitmap;
	private var _middleLeftBitmap:Bitmap;
	private var _middleCenterBitmap:Bitmap;
	private var _middleRightBitmap:Bitmap;
	private var _bottomLeftBitmap:Bitmap;
	private var _bottomCenterBitmap:Bitmap;
	private var _bottomRightBitmap:Bitmap;

	private var top:Int = 0;
	private var right:Int = 0;
	private var bottom:Int = 0;
	private var left:Int = 0;
	private var center:Int = 0;
	private var middle:Int = 0;

	private var _width:Float = 0.0;

	#if (flash && haxe_ver < 4.3) @:getter(width) #else override #end private function get_width():Float {
		return this._width;
	}

	#if (flash && haxe_ver < 4.3) @:setter(width) #else override #end private function set_width(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end {
		if (this._width == value) {
			return #if (!flash || haxe_ver >= 4.3) this._width #end;
		}
		this._width = value;
		if (this._allowRefresh) {
			this.draw();
		}
		#if (!flash || haxe_ver >= 4.3)
		return this._width;
		#end
	}

	private var _height:Float = 0.0;

	#if (flash && haxe_ver < 4.3) @:getter(height) #else override #end private function get_height():Float {
		return this._height;
	}

	#if (flash && haxe_ver < 4.3) @:setter(height) #else override #end private function set_height(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end {
		if (this._height == value) {
			return #if (!flash || haxe_ver >= 4.3) this._height #end;
		}
		this._height = value;
		if (this._allowRefresh) {
			this.draw();
		}
		#if (!flash || haxe_ver >= 4.3)
		return this._height;
		#end
	}

	private var _smoothing:Bool = false;

	/**
		Controls whether or not the bitmap is smoothed when scaled.

		@see [`openfl.display.Bitmap.smoothing`](https://api.openfl.org/openfl/display/Bitmap.html#smoothing)

		@since 1.0.0
	**/
	public var smoothing(get, set):Bool;

	private function get_smoothing():Bool {
		return this._smoothing;
	}

	private function set_smoothing(value:Bool):Bool {
		if (this._smoothing == value) {
			return this._smoothing;
		}
		this._smoothing = value;
		if (this._allowRefresh) {
			this.draw();
		}
		return this._smoothing;
	}

	private var _bitmapData:BitmapData;

	/**
		The `BitmapData` object being referenced.

		@see [`openfl.display.Bitmap.bitmapData`](https://api.openfl.org/openfl/display/Bitmap.html#bitmapData)

		@since 1.0.0
	**/
	public var bitmapData(get, set):BitmapData;

	private function get_bitmapData():BitmapData {
		return this._bitmapData;
	}

	private function set_bitmapData(value:BitmapData):BitmapData {
		if (this._bitmapData == value) {
			return this._bitmapData;
		}
		this._bitmapData = value;
		if (this._bitmapData == null) {
			throw new ArgumentError("Invalid BitmapData");
		}
		if (this._allowRefresh) {
			this.refreshSubBitmapData();
			this.draw();
		}
		return this._bitmapData;
	}

	private var _scale9Grid:Rectangle;

	#if (flash && haxe_ver < 4.3) @:getter(scale9Grid) #else override #end private function get_scale9Grid():Rectangle {
		return this._scale9Grid;
	}

	#if (flash && haxe_ver < 4.3) @:setter(scale9Grid) #else override #end private function set_scale9Grid(value:Rectangle):#if (!flash || haxe_ver >= 4.3) Rectangle #else Void #end {
		if (this._scale9Grid == value || (this._scale9Grid != null && this._scale9Grid.equals(value))) {
			return #if (!flash || haxe_ver >= 4.3) this._scale9Grid #end;
		}
		this._scale9Grid = value;
		if (this._allowRefresh) {
			this.refreshSubBitmapData();
			this.draw();
		}
		#if (!flash || haxe_ver >= 4.3)
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
		this.right = Std.int(Math.max(0.0, this._bitmapData.width - this.left - this.center));
		this.bottom = Std.int(Math.max(0.0, this._bitmapData.height - this.top - this.middle));

		this._point.setTo(0.0, 0.0);

		this.topLeft = new BitmapData(this.left, this.top);
		this._rectangle.setTo(0.0, 0.0, this.topLeft.width, this.topLeft.height);
		this.topLeft.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.topCenter = new BitmapData(this.center, this.top);
		this._rectangle.setTo(this.left, 0.0, this.topCenter.width, this.topCenter.height);
		this.topCenter.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.topRight = new BitmapData(this.right, this.top);
		this._rectangle.setTo(this.left + this.center, 0.0, this.topRight.width, this.topRight.height);
		this.topRight.copyPixels(this._bitmapData, this._rectangle, this._point);

		this.middleLeft = new BitmapData(this.left, this.middle);
		this._rectangle.setTo(0.0, this.top, this.middleLeft.width, this.middleLeft.height);
		this.middleLeft.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.middleCenter = new BitmapData(this.center, this.middle);
		this._rectangle.setTo(this.left, this.top, this.middleCenter.width, this.middleCenter.height);
		this.middleCenter.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.middleRight = new BitmapData(this.right, this.middle);
		this._rectangle.setTo(this.left + this.center, this.top, this.middleRight.width, this.middleRight.height);
		this.middleRight.copyPixels(this._bitmapData, this._rectangle, this._point);

		this.bottomLeft = new BitmapData(this.top, this.bottom);
		this._rectangle.setTo(0.0, this.top + this.middle, this.bottomLeft.width, this.bottomLeft.height);
		this.bottomLeft.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.bottomCenter = new BitmapData(this.center, this.bottom);
		this._rectangle.setTo(this.left, this.top + this.middle, this.bottomCenter.width, this.bottomCenter.height);
		this.bottomCenter.copyPixels(this._bitmapData, this._rectangle, this._point);
		this.bottomRight = new BitmapData(this.right, this.bottom);
		this._rectangle.setTo(this.left + this.center, this.top + this.middle, this.bottomRight.width, this.bottomRight.height);
		this.bottomRight.copyPixels(this._bitmapData, this._rectangle, this._point);
	}

	private function draw():Void {
		if (this._width == 0 || this._height == 0) {
			// nothing to draw
			this.cleanupBitmaps();
			return;
		}

		var center2 = Math.max(0.0, this._width - this.left - this.right);
		var middle2 = Math.max(0.0, this._height - this.top - this.bottom);

		var left2:Float = this.left;
		var right2:Float = this.right;
		var minWidth = this.left + this.right;
		if (this._width < minWidth) {
			var ratio = this._width / minWidth;
			left2 *= ratio;
			right2 *= ratio;
		}

		var top2:Float = this.top;
		var bottom2:Float = this.bottom;
		var minHeight = this.top + this.bottom;
		if (this._height < minHeight) {
			var ratio = this._height / minHeight;
			top2 *= ratio;
			bottom2 *= ratio;
		}

		if (this.topLeft != null) {
			if (this._topLeftBitmap == null) {
				this._topLeftBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._topLeftBitmap);
			}
			this._topLeftBitmap.bitmapData = this.topLeft;
			this._topLeftBitmap.smoothing = this._smoothing;
			this._topLeftBitmap.x = 0.0;
			this._topLeftBitmap.y = 0.0;
			this._topLeftBitmap.width = left2;
			this._topLeftBitmap.height = top2;
		} else if (this._topLeftBitmap != null) {
			this.removeChild(this._topLeftBitmap);
			this._topLeftBitmap = null;
		}
		if (this.topCenter != null) {
			if (this._topCenterBitmap == null) {
				this._topCenterBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._topCenterBitmap);
			}
			this._topCenterBitmap.bitmapData = this.topCenter;
			this._topCenterBitmap.smoothing = this._smoothing;
			this._topCenterBitmap.x = left2;
			this._topCenterBitmap.y = 0.0;
			this._topCenterBitmap.width = center2;
			this._topCenterBitmap.height = top2;
		} else if (this._topCenterBitmap != null) {
			this.removeChild(this._topCenterBitmap);
			this._topCenterBitmap = null;
		}
		if (this.topRight != null) {
			if (this._topRightBitmap == null) {
				this._topRightBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._topRightBitmap);
			}
			this._topRightBitmap.bitmapData = this.topRight;
			this._topRightBitmap.smoothing = this._smoothing;
			this._topRightBitmap.x = left2 + center2;
			this._topRightBitmap.y = 0.0;
			this._topRightBitmap.width = right2;
			this._topRightBitmap.height = top2;
		} else if (this._topRightBitmap != null) {
			this.removeChild(this._topRightBitmap);
			this._topRightBitmap = null;
		}

		if (this.middleLeft != null) {
			if (this._middleLeftBitmap == null) {
				this._middleLeftBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._middleLeftBitmap);
			}
			this._middleLeftBitmap.bitmapData = this.middleLeft;
			this._middleLeftBitmap.smoothing = this._smoothing;
			this._middleLeftBitmap.x = 0.0;
			this._middleLeftBitmap.y = top2;
			this._middleLeftBitmap.width = left2;
			this._middleLeftBitmap.height = middle2;
		} else if (this._middleLeftBitmap != null) {
			this.removeChild(this._middleLeftBitmap);
			this._middleLeftBitmap = null;
		}
		if (this.middleCenter != null) {
			if (this._middleCenterBitmap == null) {
				this._middleCenterBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._middleCenterBitmap);
			}
			this._middleCenterBitmap.bitmapData = this.middleCenter;
			this._middleCenterBitmap.smoothing = this._smoothing;
			this._middleCenterBitmap.x = left2;
			this._middleCenterBitmap.y = top2;
			this._middleCenterBitmap.width = center2;
			this._middleCenterBitmap.height = middle2;
		} else if (this._middleCenterBitmap != null) {
			this.removeChild(this._middleCenterBitmap);
			this._middleCenterBitmap = null;
		}
		if (this.middleRight != null) {
			if (this._middleRightBitmap == null) {
				this._middleRightBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._middleRightBitmap);
			}
			this._middleRightBitmap.bitmapData = this.middleRight;
			this._middleRightBitmap.smoothing = this._smoothing;
			this._middleRightBitmap.x = left2 + center2;
			this._middleRightBitmap.y = top2;
			this._middleRightBitmap.width = right2;
			this._middleRightBitmap.height = middle2;
		} else if (this._middleRightBitmap != null) {
			this.removeChild(this._middleRightBitmap);
			this._middleRightBitmap = null;
		}

		if (this.bottomLeft != null) {
			if (this._bottomLeftBitmap == null) {
				this._bottomLeftBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._bottomLeftBitmap);
			}
			this._bottomLeftBitmap.bitmapData = this.bottomLeft;
			this._bottomLeftBitmap.smoothing = this._smoothing;
			this._bottomLeftBitmap.x = 0.0;
			this._bottomLeftBitmap.y = top2 + middle2;
			this._bottomLeftBitmap.width = left2;
			this._bottomLeftBitmap.height = bottom2;
		} else if (this._bottomLeftBitmap != null) {
			this.removeChild(this._bottomLeftBitmap);
			this._bottomLeftBitmap = null;
		}
		if (this.bottomCenter != null) {
			if (this._bottomCenterBitmap == null) {
				this._bottomCenterBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._bottomCenterBitmap);
			}
			this._bottomCenterBitmap.bitmapData = this.bottomCenter;
			this._bottomCenterBitmap.smoothing = this._smoothing;
			this._bottomCenterBitmap.x = left2;
			this._bottomCenterBitmap.y = top2 + middle2;
			this._bottomCenterBitmap.width = center2;
			this._bottomCenterBitmap.height = bottom2;
		} else if (this._bottomCenterBitmap != null) {
			this.removeChild(this._bottomCenterBitmap);
			this._bottomCenterBitmap = null;
		}
		if (this.bottomRight != null) {
			if (this._bottomRightBitmap == null) {
				this._bottomRightBitmap = new Bitmap(null, NEVER, this._smoothing);
				this.addChild(this._bottomRightBitmap);
			}
			this._bottomRightBitmap.bitmapData = this.bottomRight;
			this._bottomRightBitmap.smoothing = this._smoothing;
			this._bottomRightBitmap.x = left2 + center2;
			this._bottomRightBitmap.y = top2 + middle2;
			this._bottomRightBitmap.width = right2;
			this._bottomRightBitmap.height = bottom2;
		} else if (this._bottomRightBitmap != null) {
			this.removeChild(this._bottomRightBitmap);
			this._bottomRightBitmap = null;
		}
	}

	private function cleanupBitmaps():Void {
		if (this._topLeftBitmap != null) {
			this.removeChild(this._topLeftBitmap);
			this._topLeftBitmap = null;
		}
		if (this._topCenterBitmap != null) {
			this.removeChild(this._topCenterBitmap);
			this._topCenterBitmap = null;
		}
		if (this._topRightBitmap != null) {
			this.removeChild(this._topRightBitmap);
			this._topRightBitmap = null;
		}
		if (this._middleLeftBitmap != null) {
			this.removeChild(this._middleLeftBitmap);
			this._middleLeftBitmap = null;
		}
		if (this._middleCenterBitmap != null) {
			this.removeChild(this._middleCenterBitmap);
			this._middleCenterBitmap = null;
		}
		if (this._middleRightBitmap != null) {
			this.removeChild(this._middleRightBitmap);
			this._middleRightBitmap = null;
		}
		if (this._bottomLeftBitmap != null) {
			this.removeChild(this._bottomLeftBitmap);
			this._bottomLeftBitmap = null;
		}
		if (this._bottomCenterBitmap != null) {
			this.removeChild(this._bottomCenterBitmap);
			this._bottomCenterBitmap = null;
		}
		if (this._bottomRightBitmap != null) {
			this.removeChild(this._bottomRightBitmap);
			this._bottomRightBitmap = null;
		}
	}
}
