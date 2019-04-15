package feathers.controls;

import openfl.system.Capabilities;
import openfl.events.Event;
import feathers.utils.ScreenDensityScaleCalculator;
import feathers.utils.MathUtil;

/**
	An optional root class for Feathers applications that will automatically
	scale the application based on the screen density of the device.

	@since 1.0.0
**/
class Application extends LayoutGroup {
	private static inline final IOS_TABLET_DENSITY_SCALE_FACTOR = 1.23484848484848;

	public function new() {
		super();

		this.addEventListener(Event.ADDED_TO_STAGE, application_addedToStageHandler);
	}

	private var _scaler:ScreenDensityScaleCalculator;
	private var _calculatedScaleFactor:Float;

	public var customScale(default, set):Null<Float> = null;

	private function set_customScale(value:Null<Float>):Null<Float> {
		if (this.customScale == value) {
			return this.customScale;
		}
		this.customScale = value;
		this.refreshDimensions();
		return this.customScale;
	}

	private function refreshDimensions():Void {
		if (this.stage == null) {
			return;
		}
		var scaleFactor = 1.0;
		if (this.customScale != null) {
			scaleFactor = this.customScale;
		} else {
			#if (desktop || web)
			this._scaler = null;
			scaleFactor = this.stage.window.scale;
			#else
			if (this._scaler == null) {
				this._scaler = new ScreenDensityScaleCalculator();
				this._scaler.addScaleForDensity(120, 0.75); // ldpi
				this._scaler.addScaleForDensity(160, 1); // mdpi
				this._scaler.addScaleForDensity(240, 1.5); // hdpi
				this._scaler.addScaleForDensity(320, 2); // xhdpi
				this._scaler.addScaleForDensity(480, 3); // xxhdpi
				this._scaler.addScaleForDensity(640, 4); // xxxhpi
			}
			scaleFactor = this._scaler.getScale(Capabilities.screenDPI);
			#end
		}
		trace("scale factor:", scaleFactor, this.stage.window.scale, this.stage.contentsScaleFactor, Capabilities.screenDPI);
		this.scaleX = scaleFactor;
		this.scaleY = scaleFactor;
		var needsToBeDivisibleByTwo = Math.floor(scaleFactor) != scaleFactor;
		var appWidth:Float = Math.floor(this.stage.stageWidth / scaleFactor);
		if (needsToBeDivisibleByTwo) {
			appWidth = MathUtil.roundDownToNearest(appWidth, 2);
		}
		this.width = appWidth;
		var appHeight:Float = Math.floor(this.stage.stageHeight / scaleFactor);
		if (needsToBeDivisibleByTwo) {
			appHeight = MathUtil.roundDownToNearest(appHeight, 2);
		}
		this.height = appHeight;
	}

	private function application_addedToStageHandler(event:Event):Void {
		this.addEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
		this.refreshDimensions();
	}

	private function application_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, application_removedFromStageHandler);
		this.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
	}

	private function stage_resizeHandler(event:Event):Void {
		this.refreshDimensions();
	}
}
