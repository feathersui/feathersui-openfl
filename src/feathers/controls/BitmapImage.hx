/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.skins.RectangleSkin;
import feathers.utils.ScaleUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.StageScaleMode;
import openfl.geom.Rectangle;

/**
	Displays `BitmapData` as a Feathers UI component.

	@see [Tutorial: How to use the BitmapImage component](https://feathersui.com/learn/haxe-openfl/bitmap-image/)
	@see `feathers.controls.AssetLoader`

	@since 1.4.0
**/
@:styleContext
class BitmapImage extends FeathersControl {
	/**
		Creates a new `BitmapImage` object.

		@since 1.4.0
	**/
	public function new(?source:BitmapData) {
		initializeBitmapImageTheme();
		super();

		this.source = source;
	}

	private var content:Bitmap;
	private var _contentMeasurements:Measurements = new Measurements();

	private var _sourceScale:Float = 1.0;

	/**
		Scales the source content for measurement. For example, if assets are
		designed for a scale factor of 2.0, they can be displayed at 0.5
		scale to appear crisp (because displays bitmaps at the original
		dimensions, as if the scale factor were 1.0).

		```haxe
		loader.sourceScale = 0.5;
		```

		@default 1.0

		@since 1.4.0
	**/
	public var sourceScale(get, set):Float;

	private function get_sourceScale():Float {
		return this._sourceScale;
	}

	private function set_sourceScale(value:Float):Float {
		if (this._sourceScale == value) {
			return this._sourceScale;
		}
		this._sourceScale = value;
		this.setInvalid(SIZE);
		return this._sourceScale;
	}

	private var _source:BitmapData;

	/**
		Sets the image's source `BitmapData`.

		The following example sets the source to a `BitmapData` asset:

		```haxe
		var bmd = Assets.getBitmapData("my-asset-name");
		loader.source = bmd;
		```

		@since 1.4.0
	**/
	@:inspectable
	public var source(get, set):BitmapData;

	private function get_source():BitmapData {
		return this._source;
	}

	private function set_source(value:BitmapData):BitmapData {
		if (this._source == value) {
			return this._source;
		}
		if (this.content != null) {
			this.removeChild(this.content);
			this.content = null;
		}
		this._source = value;
		if (this._source != null) {
			var bitmap = this.createBitmap(this._source);
			this._contentMeasurements.save(bitmap);
			this.addChild(bitmap);
			this.content = bitmap;
		}
		this.setInvalid(DATA);
		return this._source;
	}

	/**
		The original width of the `source` asset, measured in pixels. May return
		`null`, if the `source` is `null`.

		@see `BitmapImage.source`
		@see `BitmapImage.originalSourceHeight`

		@since 1.4.0
	**/
	public var originalSourceWidth(get, never):Null<Float>;

	private function get_originalSourceWidth():Null<Float> {
		if (this._contentMeasurements == null) {
			return null;
		}
		return this._contentMeasurements.width;
	}

	/**
		The original height of the bitmap data, measured in pixels. May return
		`null`, if the `source` is `null`.

		@see `BitmapImage.source`
		@see `BitmapImage.originalSourceWidth`

		@since 1.4.0
	**/
	public var originalSourceHeight(get, never):Null<Float>;

	private function get_originalSourceHeight():Null<Float> {
		if (this._contentMeasurements == null) {
			return null;
		}
		return this._contentMeasurements.height;
	}

	private var _scaleModeMask:DisplayObject = null;

	private var _scaleMode:StageScaleMode = StageScaleMode.SHOW_ALL;

	/**
		Determines how the `BitmapData` will be scaled within the width and
		height of the `BitmapImage` instance. Uses the same constants from
		[`StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)
		that are used to scale the OpenFL stage.

		The following example maintains the aspect ratio of the asset, but
		displays no border, and may crop it to fit:

		```haxe
		loader.scaleMode = StageScaleMode.NO_BORDER
		```

		@see [`openfl.display.StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)

		@since 1.4.0
	**/
	public var scaleMode(get, set):StageScaleMode;

	private function get_scaleMode():StageScaleMode {
		return this._scaleMode;
	}

	private function set_scaleMode(value:StageScaleMode):StageScaleMode {
		if (this._scaleMode == value) {
			return this._scaleMode;
		}
		this._scaleMode = value;
		this.setInvalid(LAYOUT);
		return this._scaleMode;
	}

	private function initializeBitmapImageTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelBitmapImageStyles.initialize();
		#end
	}

	override public function dispose():Void {
		this.source = null;
		super.dispose();
	}

	override private function update():Void {
		this.measure();
		this.layoutChildren();
	}

	private function measure():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var contentWidth = this._contentMeasurements.width;
		var contentHeight = this._contentMeasurements.height;
		if (contentWidth != null && this._sourceScale != 1.0) {
			contentWidth *= this._sourceScale;
		}
		if (contentHeight != null && this._sourceScale != 1.0) {
			contentHeight *= this._sourceScale;
		}
		var widthScale = 1.0;
		var heightScale = 1.0;
		if (this.content != null && this._scaleMode != StageScaleMode.NO_SCALE) {
			if (!needsWidth) {
				widthScale = this.explicitWidth / contentWidth;
			} else if (this.explicitMaxWidth != null && this.explicitMaxWidth < contentWidth) {
				widthScale = this.explicitMaxWidth / contentWidth;
			} else if (this.explicitMinWidth != null && this.explicitMinWidth > contentWidth) {
				widthScale = this.explicitMinWidth / contentWidth;
			}
			if (!needsHeight) {
				heightScale = this.explicitHeight / contentHeight;
			} else if (this.explicitMaxHeight != null && this.explicitMaxHeight < contentHeight) {
				heightScale = this.explicitMaxHeight / contentHeight;
			} else if (this.explicitMinHeight != null && this.explicitMinHeight > contentHeight) {
				heightScale = this.explicitMinHeight / contentHeight;
			}
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.content != null) {
				newWidth = contentWidth * heightScale;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this.content != null) {
				newHeight = contentHeight * widthScale;
			} else {
				newHeight = 0.0;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.content != null) {
				newMinWidth = contentWidth * heightScale;
			} else {
				newMinWidth = 0.0;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (this.content != null) {
				newMinHeight = contentHeight * widthScale;
			} else {
				newMinHeight = 0.0;
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (this.content != null) {
				newMaxWidth = contentWidth * heightScale;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.content != null) {
				newMaxHeight = contentHeight * widthScale;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutChildren():Void {
		if (this.content == null) {
			return;
		}

		var needsMask = false;
		switch (this._scaleMode) {
			case StageScaleMode.EXACT_FIT:
				this.content.x = 0.0;
				this.content.y = 0.0;
				this.content.width = this.actualWidth;
				this.content.height = this.actualHeight;
			case StageScaleMode.NO_SCALE:
				this.content.x = 0.0;
				this.content.y = 0.0;
				this._contentMeasurements.restore(this.content);
				if ((this.content is IValidating)) {
					(cast this.content : IValidating).validateNow();
				}
				needsMask = this.content.width > this.actualWidth || this.content.height > this.actualHeight;
			case StageScaleMode.NO_BORDER:
				var original = new Rectangle(0.0, 0.0, this._contentMeasurements.width, this._contentMeasurements.height);
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				var scaled = ScaleUtil.fillRectangle(original, into, into);
				this.content.x = scaled.x;
				this.content.y = scaled.y;
				this.content.width = scaled.width;
				this.content.height = scaled.height;
				needsMask = this.content.width > this.actualWidth || this.content.height > this.actualHeight;
			default: // showAll
				var original = new Rectangle(0.0, 0.0, this._contentMeasurements.width, this._contentMeasurements.height);
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				ScaleUtil.fitRectangle(original, into, into);
				this.content.x = into.x;
				this.content.y = into.y;
				this.content.width = into.width;
				this.content.height = into.height;
		}

		if (needsMask) {
			if (this._scaleModeMask == null) {
				this._scaleModeMask = new RectangleSkin(SolidColor(0xff00ff));
				this.addChild(this._scaleModeMask);
			}
			this._scaleModeMask.width = this.actualWidth;
			this._scaleModeMask.height = this.actualHeight;
			this.content.mask = this._scaleModeMask;
		} else {
			if (this._scaleModeMask != null) {
				this.removeChild(this._scaleModeMask);
				this._scaleModeMask = null;
			}
			this.content.mask = null;
		}
	}

	private function createBitmap(bitmapData:BitmapData):Bitmap {
		return new Bitmap(bitmapData);
	}
}
