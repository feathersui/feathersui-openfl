import feathers.controls.ButtonState;
import feathers.core.IUIControl;
import feathers.skins.ProgrammaticSkin;
import motion.Actuate;
import motion.easing.Sine;
import openfl.display.Shape;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;

class CustomSkin extends ProgrammaticSkin {
	private var ORIGINAL_MASK_SIZE = 10.0;

	public function new() {
		super();

		this._rippleMask = new Shape();
		this.addChild(this._rippleMask);

		this._ripple = new Shape();
		this._ripple.mask = this._rippleMask;
		this._ripple.alpha = 0.0;
		this._ripple.graphics.beginFill(0xffffff, 0.25);
		this._ripple.graphics.drawCircle(0.0, 0.0, ORIGINAL_MASK_SIZE / 2.0);
		this._ripple.graphics.endFill();
		this.addChild(this._ripple);

		this.filters = [new DropShadowFilter(4.0, 60, 0, 0.9, 10.0, 10.0)];
	}

	private var _ripple:Shape;
	private var _rippleMask:Shape;
	private var _targetScale:Float;
	private var _isActive:Bool = false;

	override private function onAddUIContext():Void {
		this.uiContext.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	override private function onRemoveUIContext():Void {
		this.uiContext.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	override private function update():Void {
		var isHover = this._stateContext.currentState == HOVER;
		var isDown = this._stateContext.currentState == DOWN;
		var fillColor = (isHover || isDown) ? 0x7e3ff2 : 0x6002ee;

		// draw the main shape
		this.graphics.clear();
		this.graphics.beginFill(fillColor);
		this.graphics.drawRoundRect(0.0, 0.0, this.actualWidth, this.actualHeight, 10.0);
		this.graphics.endFill();

		// the mask has the same rounded rectangle shape as the button
		this._rippleMask.graphics.clear();
		this._rippleMask.graphics.beginFill(0xff00ff);
		this._rippleMask.graphics.drawRoundRect(0.0, 0.0, this.actualWidth, this.actualHeight, 10.0);
		this._rippleMask.graphics.endFill();
	}

	private function hideOverlay():Void {
		Actuate.stop(this._ripple, ["scaleX", "scaleY", "alpha"]);
		this._ripple.scaleX = this._targetScale;
		this._ripple.scaleY = this._targetScale;
		this._ripple.alpha = 1.0;
		// hide the ripple overlay by fading it out
		Actuate.tween(this._ripple, 0.2, {alpha: 0.0}).ease(Sine.easeOut);
	}

	private function mouseDownHandler(event:MouseEvent):Void {
		Actuate.stop(this._ripple, ["scaleX", "scaleY", "alpha"]);

		this._ripple.scaleX = 0.0;
		this._ripple.scaleY = 0.0;
		this._ripple.alpha = 0.5;
		this._ripple.x = this.mouseX;
		this._ripple.y = this.mouseY;

		this._isActive = true;

		var virtualWidth = this.actualWidth + (2.0 * Math.abs((this.actualWidth / 2.0) - this.mouseX));
		var virtualHeight = this.actualHeight + (2.0 * Math.abs((this.actualHeight / 2.0) - this.mouseY));
		var newMaskSize = Math.sqrt((virtualWidth * virtualWidth) + (virtualHeight * virtualHeight));
		this._targetScale = newMaskSize / ORIGINAL_MASK_SIZE;
		// reveal the ripple overlay by scaling it up and fading it in
		Actuate.tween(this._ripple, 0.2, {scaleX: this._targetScale, scaleY: this._targetScale, alpha: 1.0})
			.ease(Sine.easeOut)
			.onComplete(downTween_onComplete);

		this.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
	}

	private function stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		if (this._isActive) {
			// the tween is still running, so we must wait
			this._isActive = false;
			return;
		}
		this.hideOverlay();
	}

	private function downTween_onComplete():Void {
		if (this._isActive) {
			// the mouse is still down, so we must wait
			this._isActive = false;
			return;
		}
		this.hideOverlay();
	}
}
