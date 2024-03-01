/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.actuators.MethodActuator;
import motion.actuators.PropertyDetails;
import motion.easing.IEasing;

/**
	Extends `MethodActuator` by adding methods to read the settings after
	they've been modified.

	@since 1.0.0
**/
class MethodEffectActuator<T> extends MethodActuator<T> implements IReadableGenericActuator {
	/**
		Creates a new `MethodEffectActuator` object from the given arguments.

		@since 1.0.0
	**/
	public function new(target:T, duration:Float, properties:Dynamic) {
		super(target, duration, properties);
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getTarget()`
	**/
	public function getTarget():Dynamic {
		return this.target;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getDuration()`
	**/
	public function getDuration():Float {
		return this.duration;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getEase()`
	**/
	public function getEase():IEasing {
		return this._ease;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getAutoVisible()`
	**/
	public function getAutoVisible():Bool {
		return this._autoVisible;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getDelay()`
	**/
	public function getDelay():Float {
		return this._delay;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getReflect()`
	**/
	public function getReflect():Bool {
		return this._reflect;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getRepeat()`
	**/
	public function getRepeat():Int {
		return this._repeat;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getReverse()`
	**/
	public function getReverse():Bool {
		return this._reverse;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getSmartRotation()`
	**/
	public function getSmartRotation():Bool {
		return this._smartRotation;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getSnapping()`
	**/
	public function getSnapping():Bool {
		return this._snapping;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnComplete()`
	**/
	public function getOnComplete():Dynamic {
		return this._onComplete;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnCompleteParams()`
	**/
	public function getOnCompleteParams():Array<Dynamic> {
		return this._onCompleteParams;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnRepeat()`
	**/
	public function getOnRepeat():Dynamic {
		return this._onRepeat;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnRepeatParams()`
	**/
	public function getOnRepeatParams():Array<Dynamic> {
		return this._onRepeatParams;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnUpdate()`
	**/
	public function getOnUpdate():Dynamic {
		return this._onUpdate;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnUpdateParams()`
	**/
	public function getOnUpdateParams():Array<Dynamic> {
		return this._onUpdateParams;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnPause()`
	**/
	public function getOnPause():Dynamic {
		return this._onPause;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnPauseParams()`
	**/
	public function getOnPauseParams():Array<Dynamic> {
		return this._onPauseParams;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnResume()`
	**/
	public function getOnResume():Dynamic {
		return this._onResume;
	}

	/**
		@see `feathers.motion.effects.actuate.IReadableGenericActuator.getOnResumeParams()`
	**/
	public function getOnResumeParams():Array<Dynamic> {
		return this._onResumeParams;
	}

	/**
		@see `feathers.motion.effects.actuate.IGotoActuator.goto()`
	**/
	public function goto(tweenPosition:Float):Void {
		var details:PropertyDetails<T>;
		var easing:Float;
		var i:Int;

		if (!initialized) {
			initialize();
		}

		if (!special) {
			easing = _ease.calculate(tweenPosition);

			for (i in 0...detailsLength) {
				details = propertyDetails[i];
				setProperty(details, details.start + (details.change * easing));
			}
		} else {
			if (!_reverse) {
				easing = _ease.calculate(tweenPosition);
			} else {
				easing = _ease.calculate(1 - tweenPosition);
			}

			var endValue:Float;

			for (i in 0...detailsLength) {
				details = propertyDetails[i];

				if (_smartRotation
					&& (details.propertyName == "rotation" || details.propertyName == "rotationX" || details.propertyName == "rotationY"
						|| details.propertyName == "rotationZ")) {
					var rotation:Float = details.change % 360;

					if (rotation > 180) {
						rotation -= 360;
					} else if (rotation < -180) {
						rotation += 360;
					}

					endValue = details.start + rotation * easing;
				} else {
					endValue = details.start + (details.change * easing);
				}

				if (!_snapping) {
					setProperty(details, endValue);
				} else {
					setProperty(details, Math.round(endValue));
				}
			}
		}

		for (i in 0...properties.start.length) {
			currentParameters[i] = Reflect.field(tweenProperties, "param" + i);
		}

		callMethod(target, currentParameters);
	}

	override private function update(currentTime:Float):Void {
		if (!paused) {
			var tweenPosition:Float = (currentTime - timeOffset) / duration;

			if (tweenPosition > 1) {
				tweenPosition = 1;
			}

			goto(tweenPosition);

			if (tweenPosition == 1) {
				if (_repeat == 0) {
					active = false;

					if (toggleVisible && getField(target, "alpha") == 0) {
						setField(target, "visible", false);
					}

					complete(true);
					return;
				} else {
					if (_onRepeat != null) {
						callMethod(_onRepeat, _onRepeatParams);
					}

					if (_reflect) {
						_reverse = !_reverse;
					}

					startTime = currentTime;
					timeOffset = startTime + _delay;

					if (_repeat > 0) {
						_repeat--;
					}
				}
			}

			if (sendChange) {
				change();
			}
		}
	}
}
