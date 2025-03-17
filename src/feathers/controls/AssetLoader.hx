/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IValidating;
import feathers.layout.Measurements;
import feathers.skins.RectangleSkin;
import feathers.utils.ScaleUtil;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.StageScaleMode;
import openfl.errors.SecurityError;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.utils.AssetType;
import openfl.utils.Future;

/**
	Loads and displays an asset using either OpenFL's asset management system or
	from a URL.

	Supports assets of the following types:

	- [`AssetType.IMAGE`](https://api.openfl.org/openfl/utils/AssetType.html#IMAGE)
	- [`AssetType.MOVIE_CLIP`](https://api.openfl.org/openfl/utils/AssetType.html#MOVIE_CLIP)

	@event openfl.events.Event.COMPLETE Dispatched when `AssetLoader.source`
	successfully completes loading asynchronously. If `AssetLoader.source` is
	pre-loaded by `openfl.utils.Assets`, this event will not be dispatched.

	@event openfl.events.ProgressEvent.PROGRESS Dispatched periodically as
	`AssetLoader.source` loads asynchronously. If `AssetLoader.source` is
	pre-loaded by `openfl.utils.Assets`, this event will not be dispatched.

	@event openfl.events.IOErrorEvent.IO_ERROR Dispatched if an IO error occurs
	while loading `AssetLoader.source`.

	@event openfl.events.SecurityErrorEvent.SECURITY_ERROR Dispatched if a
	security error occurs while loading `AssetLoader.source`.


	@see [Tutorial: How to use the AssetLoader component](https://feathersui.com/learn/haxe-openfl/asset-loader/)
	@see [`openfl.utils.Assets`](https://api.openfl.org/openfl/utils/Assets.html)
	@see `feathers.controls.BitmapImage`

	@since 1.0.0
**/
@:event(openfl.events.Event.COMPLETE)
@:event(openfl.events.ProgressEvent.PROGRESS)
@:event(openfl.events.IOErrorEvent.IO_ERROR)
@:event(openfl.events.SecurityErrorEvent.SECURITY_ERROR)
@:styleContext
class AssetLoader extends FeathersControl {
	/**
		Creates a new `AssetLoader` object.

		@since 1.0.0
	**/
	public function new(?source:String, ?completeListener:(Event) -> Void) {
		initializeAssetLoaderTheme();
		super();

		this.source = source;

		if (completeListener != null) {
			this.addEventListener(Event.COMPLETE, completeListener);
		}
	}

	private var content:DisplayObject;
	private var loader:Loader;
	private var _contentMeasurements:Measurements = new Measurements();

	private var _pendingFuture:Future<Dynamic>;

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

		@since 1.3.0
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

	private var _source:String;

	/**
		Sets the loader's source, which may be either the name of an asset or a
		URL to load the asset from the web instead.

		The following example sets the source to an asset name:

		```haxe
		loader.source = "my-asset-name";
		```

		The following example sets the source to a URL:

		```haxe
		loader.source = "https://example.com/my-asset.png";
		```

		@since 1.0.0
	**/
	@:inspectable
	public var source(get, set):String;

	private function get_source():String {
		return this._source;
	}

	private function set_source(value:String):String {
		if (this._source == value) {
			return this._source;
		}
		if (this.loader != null) {
			this.loader.unloadAndStop();
		}
		if (this.content != null) {
			this.removeChild(this.content);
			this.content = null;
		}
		this._source = value;
		if (this._source == null) {
			this._pendingFuture = null;
			this.cleanupLoader();
		} else {
			if (Assets.exists(this._source, AssetType.IMAGE)) {
				this.cleanupLoader();
				if (Assets.isLocal(this._source, AssetType.IMAGE)) {
					this._pendingFuture = null;
					var bitmapData = Assets.getBitmapData(this._source);
					var bitmap = this.createBitmap(bitmapData);
					this._contentMeasurements.save(bitmap);
					this.addChild(bitmap);
					this.content = bitmap;
				} else // async
				{
					var future = Assets.loadBitmapData(this._source);
					future.onProgress((progress, total) -> {
						this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, progress, total));
					}).onComplete(function(bitmapData:BitmapData):Void {
						if (future != this._pendingFuture) {
							// cancelled
							return;
						}
						var bitmap = this.createBitmap(bitmapData);
						this._contentMeasurements.save(bitmap);
						this.addChild(bitmap);
						this.content = bitmap;
						this.setInvalid(DATA);
						this.dispatchEvent(new Event(Event.COMPLETE));
					}).onError((event:Dynamic) -> {
						this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
					});
					this._pendingFuture = future;
				}
			} else if (Assets.exists(this._source, AssetType.MOVIE_CLIP)) {
				this.cleanupLoader();
				if (Assets.isLocal(this._source, AssetType.MOVIE_CLIP)) {
					this._pendingFuture = null;
					var movieClip = Assets.getMovieClip(this._source);
					this._contentMeasurements.save(movieClip);
					this.addChild(movieClip);
					this.content = movieClip;
				} else // async
				{
					var future = Assets.loadMovieClip(this._source);
					future.onProgress((progress, total) -> {
						this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, progress, total));
					}).onComplete(function(movieClip:MovieClip):Void {
						if (future != this._pendingFuture) {
							// cancelled
							return;
						}
						this._contentMeasurements.save(movieClip);
						this.addChild(movieClip);
						this.content = movieClip;
						this.setInvalid(DATA);
						this.dispatchEvent(new Event(Event.COMPLETE));
					}).onError((event:Dynamic) -> {
						this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
					});
					this._pendingFuture = future;
				}
			} else {
				this._pendingFuture = null;
				if (this.loader == null) {
					this.loader = new Loader();
					this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_contentLoaderInfo_completeHandler);
					this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loader_contentLoaderInfo_progressHandler);
					this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_contentLoaderInfo_ioErrorHandler);
					this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_contentLoaderInfo_securityErrorHandler);
				}
				try {
					this.loader.load(new URLRequest(this._source));
				} catch (e:Dynamic) {
					if ((e is SecurityError)) {
						var securityError:SecurityError = cast e;
						this.dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, securityError.message,
							securityError.errorID));
					}
				}
			}
		}
		this.setInvalid(DATA);
		return this._source;
	}

	/**
		The original width of the `source` asset, measured in pixels. May return
		`null`, if the `source` is `null`, or if the `source` has not yet
		completed loading.

		@see `AssetLoader.source`
		@see `AssetLoader.originalSourceHeight`

		@since 1.0.0
	**/
	public var originalSourceWidth(get, never):Null<Float>;

	private function get_originalSourceWidth():Null<Float> {
		if (this._contentMeasurements == null) {
			return null;
		}
		return this._contentMeasurements.width;
	}

	/**
		The original height of the source asset, measured in pixels. May return
		`null`, if the `source` is `null`, or if the `source` has not yet
		completed loading.

		@see `AssetLoader.source`
		@see `AssetLoader.originalSourceWidth`

		@since 1.0.0
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

		Determines how the asset will be scaled within the width and height of
		the `AssetLoader` instance. Uses the same constants from
		[`StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)
		that are used to scale the OpenFL stage.

		The following example maintains the aspect ratio of the asset, but
		displays no border, and may crop it to fit:

		```haxe
		loader.scaleMode = StageScaleMode.NO_BORDER
		```

		@see [`openfl.display.StageScaleMode`](https://api.openfl.org/openfl/display/StageScaleMode.html)

		@since 1.0.0
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

	private function initializeAssetLoaderTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelAssetLoaderStyles.initialize();
		#end
	}

	override public function dispose():Void {
		this.source = null;
		super.dispose();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);

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

	private function cleanupLoader():Void {
		if (this.loader == null) {
			return;
		}
		this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_contentLoaderInfo_completeHandler);
		this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loader_contentLoaderInfo_progressHandler);
		this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_contentLoaderInfo_ioErrorHandler);
		this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_contentLoaderInfo_securityErrorHandler);
		this.loader = null;
	}

	private function loader_contentLoaderInfo_progressHandler(event:ProgressEvent):Void {
		this.dispatchEvent(event);
	}

	private function loader_contentLoaderInfo_ioErrorHandler(event:IOErrorEvent):Void {
		this.dispatchEvent(event);
	}

	private function loader_contentLoaderInfo_securityErrorHandler(event:SecurityErrorEvent):Void {
		this.dispatchEvent(event);
	}

	private function loader_contentLoaderInfo_completeHandler(event:Event):Void {
		this.addChild(this.loader);
		this.content = this.loader;
		this._contentMeasurements.save(this.content);
		this.setInvalid(LAYOUT);
		this.dispatchEvent(event);
	}
}
