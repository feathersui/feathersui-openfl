/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.transitions;

import openfl.display.Shape;
import openfl.geom.Point;
import feathers.motion.effects.EffectInterruptBehavior;
import feathers.motion.effects.IEffectContext;
import feathers.motion.effects.actuate.ActuateEffectContext;
import feathers.motion.effects.actuate.ActuateForEffects;
import motion.Actuate;
import motion.easing.IEasing;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.errors.ArgumentError;

/**
	Creates transitions for view navigators that show or hide a display object
	masked by a growing or shrinking circle. Both display objects remain
	stationary while a mask is animated.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class IrisTransitionBuilder {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a new `IrisTransitionBuilder` object.

		@since 1.0.0
	**/
	public function new(open:Bool = true, originRatioX:Float = 0.5, originRatioY:Float = 0.5, duration:Float = 0.5, ?ease:IEasing) {
		this._open = open;
		this._originRatioX = originRatioX;
		this._originRatioY = originRatioY;
		this._duration = duration;
		this._ease = ease;
	}

	private var _open:Bool;
	private var _originRatioX:Null<Float>;
	private var _originRatioY:Null<Float>;
	private var _originX:Null<Float>;
	private var _originY:Null<Float>;
	private var _duration:Float;
	private var _ease:IEasing;
	private var _interruptBehavior:EffectInterruptBehavior;

	/**
		Sets whether the iris opens or closes.

		@since 1.0.0
	**/
	public function setOpen(open:Bool):IrisTransitionBuilder {
		this._open = open;
		return this;
	}

	/**
		Sets the x position of the origin, as a ratio of the view's width. 

		@since 1.0.0
	**/
	public function setOriginRatioX(originRatioX:Float):IrisTransitionBuilder {
		this._originRatioX = originRatioX;
		this._originX = null;
		return this;
	}

	/**
		Sets the y position of the origin, as a ratio of the view's height.

		@since 1.0.0
	**/
	public function setOriginRatioY(originRatioY:Float):IrisTransitionBuilder {
		this._originRatioY = originRatioY;
		this._originY = null;
		return this;
	}

	/**
		Sets the x position of the origin, in pixels.

		@since 1.0.0
	**/
	public function setOriginX(originX:Float):IrisTransitionBuilder {
		this._originX = originX;
		this._originRatioX = null;
		return this;
	}

	/**
		Sets the y position of the origin, in pixels.

		@since 1.0.0
	**/
	public function setOriginY(originY:Float):IrisTransitionBuilder {
		this._originY = originY;
		this._originRatioY = null;
		return this;
	}

	/**
		Sets the duration of the animation, measured in seconds.

		@since 1.0.0
	**/
	public function setDuration(duration:Float):IrisTransitionBuilder {
		this._duration = duration;
		return this;
	}

	/**
		Sets the easing function used for the animation.

		@since 1.0.0
	**/
	public function setEase(ease:IEasing):IrisTransitionBuilder {
		this._ease = ease;
		return this;
	}

	/**
		Sets the behavior of the transition when it is interrupted (whether it
		stops at the current position or jumps immediately to the end).

		@since 1.0.0
	**/
	public function setInterruptBehavior(interruptBehavior:EffectInterruptBehavior):IrisTransitionBuilder {
		this._interruptBehavior = interruptBehavior;
		return this;
	}

	/**
		Returns the transition function.

		@since 1.0.0
	**/
	public function build():(DisplayObject, DisplayObject) -> IEffectContext {
		var open = this._open;
		var originX = this._originX;
		var originY = this._originY;
		var originRatioX = this._originRatioX;
		var originRatioY = this._originRatioY;
		var duration = this._duration;
		var ease = this._ease;
		var interruptBehavior = this._interruptBehavior;
		return (oldView:DisplayObject, newView:DisplayObject) -> {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var parent:DisplayObjectContainer = null;
			var width = 0.0;
			var height = 0.0;
			var oldViewMask:Shape = null;
			var newViewMask:Shape = null;
			var oldViewOldMask:DisplayObject = null;
			var newViewOldMask:DisplayObject = null;
			if (oldView != null) {
				parent = oldView.parent;
				width = oldView.width;
				height = oldView.height;
				oldViewOldMask = oldView.mask;
			}
			if (newView != null) {
				parent = newView.parent;
				width = Math.max(width, newView.width);
				height = Math.max(height, newView.height);
				newViewOldMask = newView.mask;
			}

			var startScale = open ? 0.0 : 1.0;
			var endScale = open ? 1.0 : 0.0;

			var currentOriginX = originX;
			if (currentOriginX == null) {
				currentOriginX = width * originRatioX;
			}
			var currentOriginY = originY;
			if (currentOriginY == null) {
				currentOriginY = height * originRatioY;
			}

			var halfWidth = width / 2.0;
			var halfHeight = height / 2.0;
			var p1 = new Point(halfWidth, halfHeight);
			var p2 = new Point(currentOriginX, currentOriginY);
			var radiusFromCenter = p1.length;
			var radius = radiusFromCenter;
			if (!p1.equals(p2)) {
				var distanceFromCenterToOrigin = Point.distance(p1, p2);
				radius = radiusFromCenter + distanceFromCenterToOrigin;
			}

			if (newView != null && open) {
				newViewMask = new Shape();
				newViewMask.x = currentOriginX;
				newViewMask.y = currentOriginY;
				newViewMask.graphics.beginFill(0xff00ff);
				newViewMask.graphics.drawCircle(0.0, 0.0, radius);
				newViewMask.graphics.endFill();
				newViewMask.scaleX = 0.0;
				newViewMask.scaleY = 0.0;
				newView.mask = newViewMask;
				parent.addChild(newViewMask);

				if (oldView != null) {
					var oldViewIndex = parent.getChildIndex(oldView);
					var newViewIndex = parent.getChildIndex(newView);
					if (oldViewIndex > newViewIndex) {
						// old view should be on bottom
						parent.swapChildren(oldView, newView);
					}
				}
			}
			if (oldView != null && !open) {
				oldViewMask = new Shape();
				oldViewMask.x = currentOriginX;
				oldViewMask.y = currentOriginY;
				oldViewMask.graphics.beginFill(0xff00ff);
				oldViewMask.graphics.drawCircle(0, 0, radius);
				oldViewMask.graphics.endFill();
				oldView.mask = oldViewMask;
				parent.addChild(oldViewMask);

				if (newView != null) {
					var oldViewIndex = parent.getChildIndex(oldView);
					var newViewIndex = parent.getChildIndex(newView);
					if (newViewIndex > oldViewIndex) {
						// new view should be on bottom
						parent.swapChildren(oldView, newView);
					}
				}
			}

			var actuator = ActuateForEffects.update((scale:Float) -> {
				if (oldViewMask != null) {
					oldViewMask.scaleX = scale;
					oldViewMask.scaleY = scale;
				}
				if (newViewMask != null) {
					newViewMask.scaleX = scale;
					newViewMask.scaleY = scale;
				}
			}, duration, [startScale], [endScale]);
			if (ease != null) {
				actuator.ease(ease);
			}
			actuator.onComplete(() -> {
				if (oldView != null) {
					oldView.mask = oldViewOldMask;
				}
				if (newView != null) {
					newView.mask = newViewOldMask;
				}
				if (oldViewMask != null) {
					parent.removeChild(oldViewMask);
				}
				if (newViewMask != null) {
					parent.removeChild(newViewMask);
				}
			});
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}
