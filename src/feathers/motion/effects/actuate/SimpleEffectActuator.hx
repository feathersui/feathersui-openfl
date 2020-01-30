/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.easing.IEasing;
import motion.actuators.PropertyDetails;
import motion.actuators.SimpleActuator;

/**
	Extends `SimpleActuator` by adding methods to read the settings after
	they've been modified.

	@since 1.0.0
**/
class SimpleEffectActuator<T, U> extends SimpleActuator<T, U> implements IReadableGenericActuator {
	/**
		Creates a new `SimpleEffectActuator` object from the given arguments.

		@since 1.0.0
	**/
	public function new(target:T, duration:Float, properties:Dynamic) {
		super(target, duration, properties);
	}

	public function getTarget():Dynamic {
		return this.target;
	}

	public function getDuration():Float {
		return this.duration;
	}

	public function getEase():IEasing {
		return this._ease;
	}

	public function getAutoVisible():Bool {
		return this._autoVisible;
	}

	public function getDelay():Float {
		return this._delay;
	}

	public function getReflect():Bool {
		return this._reflect;
	}

	public function getRepeat():Int {
		return this._repeat;
	}

	public function getReverse():Bool {
		return this._reverse;
	}

	public function getSmartRotation():Bool {
		return this._smartRotation;
	}

	public function getSnapping():Bool {
		return this._snapping;
	}

	public function getOnComplete():Dynamic {
		return this._onComplete;
	}

	public function getOnCompleteParams():Array<Dynamic> {
		return this._onCompleteParams;
	}

	public function getOnRepeat():Dynamic {
		return this._onRepeat;
	}

	public function getOnRepeatParams():Array<Dynamic> {
		return this._onRepeatParams;
	}

	public function getOnUpdate():Dynamic {
		return this._onUpdate;
	}

	public function getOnUpdateParams():Array<Dynamic> {
		return this._onUpdateParams;
	}

	public function getOnPause():Dynamic {
		return this._onPause;
	}

	public function getOnPauseParams():Array<Dynamic> {
		return this._onPauseParams;
	}

	public function getOnResume():Dynamic {
		return this._onResume;
	}

	public function getOnResumeParams():Array<Dynamic> {
		return this._onResumeParams;
	}

	public function goto(tweenPosition:Float):Void {
		var details:PropertyDetails<U>;
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
