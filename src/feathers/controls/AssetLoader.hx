/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.MovieClip;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.display.Loader;
import openfl.geom.Rectangle;
import openfl.display.StageScaleMode;
import openfl.display.DisplayObject;
import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.layout.Measurements;
import feathers.utils.ScaleUtil;

/**
	Loads and displays an asset using either OpenFL's asset management system or
	from a URL.

	Supports assets of the following types:

	- [`AssetType.IMAGE`](https://api.openfl.org/openfl/utils/AssetType.html#IMAGE)
	- [`AssetType.MOVIE_CLIP`](https://api.openfl.org/openfl/utils/AssetType.html#MOVIE_CLIP)


	@see [Tutorial: How to use the AssetLoader component](https://feathersui.com/learn/haxe-openfl/asset-loader/)
	@see [`openfl.utils.Assets`](https://api.openfl.org/openfl/utils/Assets.html)

	@since 1.0.0
**/
class AssetLoader extends FeathersControl {
	/**
		Creates a new `AssetLoader` object.

		@since 1.0.0
	**/
	public function new() {
		super();
	}

	private var content:DisplayObject;
	private var loader:Loader;
	private var _contentMeasurements:Measurements = new Measurements();

	/**
		Sets the loader's source, which may be either the name of an asset or a
		URL to load the asset from the web instead.

		The following example sets the source to an asset name:

		```hx
		loader.source = "my-asset-name";
		```

		The following example sets the source to a URL:

		```hx
		loader.source = "https://example.com/my-asset.png";
		```

		@since 1.0.0
	**/
	public var source(default, set):String;

	private function set_source(value:String):String {
		if (this.source == value) {
			return this.source;
		}
		if (this.loader != null) {
			this.loader.unloadAndStop();
		}
		if (this.content != null) {
			this.removeChild(this.content);
			this.content = null;
		}
		this.source = value;
		if (this.source == null) {
			this.cleanupLoader();
		} else {
			if (Assets.exists(this.source, AssetType.IMAGE)) {
				this.cleanupLoader();
				if (Assets.isLocal(this.source, AssetType.IMAGE)) {
					var bitmapData = Assets.getBitmapData(this.source);
					var bitmap = new Bitmap(bitmapData);
					this._contentMeasurements.save(bitmap);
					this.addChild(bitmap);
					this.content = bitmap;
				} else // async
				{
					var future = Assets.loadBitmapData(this.source).onComplete((bitmapData:BitmapData) -> {
						var bitmap = new Bitmap(bitmapData);
						this._contentMeasurements.save(bitmap);
						this.addChild(bitmap);
						this.content = bitmap;
						this.setInvalid(InvalidationFlag.DATA);
						this.dispatchEvent(new Event(Event.COMPLETE));
					}).onError((event:Dynamic) -> {
							this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
						});
				}
			} else if (Assets.exists(this.source, AssetType.MOVIE_CLIP)) {
				this.cleanupLoader();
				if (Assets.isLocal(this.source, AssetType.MOVIE_CLIP)) {
					var movieClip = Assets.getMovieClip(this.source);
					this._contentMeasurements.save(movieClip);
					this.addChild(movieClip);
					this.content = movieClip;
				} else // async
				{
					var future = Assets.loadMovieClip(this.source).onComplete((movieClip:MovieClip) -> {
						this._contentMeasurements.save(movieClip);
						this.addChild(movieClip);
						this.content = movieClip;
						this.setInvalid(InvalidationFlag.DATA);
						this.dispatchEvent(new Event(Event.COMPLETE));
					}).onError((event:Dynamic) -> {
							this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
						});
				}
			} else {
				if (this.loader == null) {
					this.loader = new Loader();
					this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_contentLoaderInfo_completeHandler);
					this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_contentLoaderInfo_ioErrorHandler);
					this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_contentLoaderInfo_securityErrorHandler);
					this.addChild(this.loader);
				}
				this.loader.load(new URLRequest(this.source));
			}
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.source;
	}

	/**

		Determines how the asset will be scaled within the width and height of
		the `AssetLoader` instance. Uses the same constants from
		[`StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)
		that are used to scale the OpenFL stage.

		The following example maintains the aspect ratio of the asset, but
		displays no border, and may crop it to fit:

		```hx
		loader.scaleMode = StageScaleMode.NO_BORDER
		```

		@see [`openfl.display.StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)

		@since 1.0.0
	**/
	public var scaleMode(default, set):StageScaleMode = StageScaleMode.SHOW_ALL;

	private function set_scaleMode(value:StageScaleMode):StageScaleMode {
		if (this.scaleMode == value) {
			return this.scaleMode;
		}
		this.scaleMode = value;
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.scaleMode;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);

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
		var widthScale = 1.0;
		var heightScale = 1.0;
		if (this.content != null && this.scaleMode != StageScaleMode.NO_SCALE) {
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

		// this ensures that an AssetLoader can recover from width or height
		// being set to 0.0 by percentWidth or percentHeight
		if (needsWidth && needsMinWidth) {
			// if no width values are set, use the original content height
			// for the minHeight
			widthScale = 1.0;
		}
		if (needsHeight && needsMinHeight) {
			// if no height values are set, use the original content width
			// for the minWidth
			heightScale = 1.0;
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
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.content != null) {
				newMaxHeight = contentHeight * widthScale;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
		}

		// if the minimum is not set explicitly, but the maximum is, use the
		// maximum for the minimum
		// BowlerHatLLC/feathersui-starling#1541
		if (needsMinWidth && !needsMaxWidth && minWidth < this.explicitMaxWidth) {
			minWidth = this.explicitMaxWidth;
		}
		if (needsMinHeight && !needsMaxHeight && minHeight < this.explicitMaxHeight) {
			minHeight = this.explicitMaxHeight;
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function layoutChildren():Void {
		if (this.content == null) {
			return;
		}

		switch (this.scaleMode) {
			case StageScaleMode.EXACT_FIT:
				this.content.x = 0.0;
				this.content.y = 0.0;
				this.content.width = this.actualWidth;
				this.content.height = this.actualHeight;
			case StageScaleMode.NO_SCALE:
				this.content.x = 0.0;
				this.content.y = 0.0;
				this._contentMeasurements.restore(this.content);
			case StageScaleMode.NO_BORDER:
				var original = new Rectangle(0.0, 0.0, this._contentMeasurements.width, this._contentMeasurements.height);
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				ScaleUtil.fillRectangle(original, into, into);
				this.content.x = into.x;
				this.content.y = into.y;
				this.content.width = into.width;
				this.content.height = into.height;
			default: // showAll
				var original = new Rectangle(0.0, 0.0, this._contentMeasurements.width, this._contentMeasurements.height);
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				ScaleUtil.fitRectangle(original, into, into);
				this.content.x = into.x;
				this.content.y = into.y;
				this.content.width = into.width;
				this.content.height = into.height;
		}
	}

	private function cleanupLoader():Void {
		if (this.loader == null) {
			return;
		}
		this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_contentLoaderInfo_completeHandler);
		this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_contentLoaderInfo_ioErrorHandler);
		this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_contentLoaderInfo_securityErrorHandler);
		this.loader = null;
	}

	private function loader_contentLoaderInfo_ioErrorHandler(event:IOErrorEvent):Void {
		this.dispatchEvent(event);
	}

	private function loader_contentLoaderInfo_securityErrorHandler(event:SecurityErrorEvent):Void {
		this.dispatchEvent(event);
	}

	private function loader_contentLoaderInfo_completeHandler(event:Event):Void {
		this.content = this.loader;
		this._contentMeasurements.save(this.content);
		this.setInvalid(InvalidationFlag.LAYOUT);
		this.dispatchEvent(event);
	}
}
