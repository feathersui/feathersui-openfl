/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

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

class AssetLoader extends FeathersControl {
	public function new() {
		super();
	}

	private var content:DisplayObject;
	private var loader:Loader;
	private var _contentMeasurements:Measurements = new Measurements();

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
				var bitmapData = Assets.getBitmapData(this.source);
				var bitmap = new Bitmap(bitmapData);
				this._contentMeasurements.save(bitmap);
				this.addChild(bitmap);
				this.content = bitmap;
			} else if (Assets.exists(this.source, AssetType.MOVIE_CLIP)) {
				this.cleanupLoader();
				var movieClip = Assets.getMovieClip(this.source);
				this._contentMeasurements.save(movieClip);
				this.addChild(movieClip);
				this.content = movieClip;
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

		this.autoSizeIfNeeded();
		this.layoutChildren();
	}

	private function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.content != null) {
				newWidth = this._contentMeasurements.width;
			} else {
				newWidth = 0.0;
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this.content != null) {
				newHeight = this._contentMeasurements.height;
			} else {
				newHeight = 0.0;
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.content != null) {
				newMinWidth = this._contentMeasurements.minWidth;
			} else {
				newMinWidth = 0.0;
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (this.content != null) {
				newMinHeight = this._contentMeasurements.minHeight;
			} else {
				newMinHeight = 0.0;
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (this.content != null) {
				newMaxWidth = this._contentMeasurements.maxWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.content != null) {
				newMaxHeight = this._contentMeasurements.maxHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
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
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				ScaleUtil.fillRectangle(this._contentMeasurements.width, this._contentMeasurements.height, into, into);
				this.content.x = into.x;
				this.content.y = into.y;
				this.content.width = into.width;
				this.content.height = into.height;
			default: // showAll
				var into = new Rectangle(0.0, 0.0, this.actualWidth, this.actualHeight);
				ScaleUtil.fitRectangle(this._contentMeasurements.width, this._contentMeasurements.height, into, into);
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
