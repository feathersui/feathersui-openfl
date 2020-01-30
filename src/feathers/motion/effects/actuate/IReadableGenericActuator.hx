/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.easing.IEasing;
import motion.actuators.IGenericActuator;

/**
	An extension to `IGenericActuator` that makes the settings readable after
	they've been modified.

	@since 1.0.0
**/
interface IReadableGenericActuator extends IGenericActuator extends IGotoActuator {
	/**
		The target of the tween
		@return	The target of the tween

		@since 1.0.0
	**/
	public function getTarget():Dynamic;

	/**
		The duration of the tween
		@return	The duration, in seconds

		@since 1.0.0
	**/
	public function getDuration():Dynamic;

	/**
		Gets whether toggles automatically based on alpha values
		@return		Whether autoVisible should be enabled

		@since 1.0.0
	**/
	public function getAutoVisible():Bool;

	/**
		The delay before a tween is executed
		@return		The amount of seconds to delay

		@since 1.0.0
	**/
	public function getDelay():Float;

	/**
		The easing which is used when running the tween
		@return		An easing equation, like Elastic.easeIn or Quad.easeOut

		@since 1.0.0
	**/
	public function getEase():IEasing;

	/**
		Returns whether the reverse value automatically changes when the tween repeats
		@return		Whether reflect should be enabled

		@since 1.0.0
	**/
	public function getReflect():Bool;

	/**
		Returns whether the tween repeats after it finishes
		@return		The number of times you would like the tween to repeat, or -1 if the tween should repeat indefinitely

		@since 1.0.0
	**/
	public function getRepeat():Int;

	/**
		Gets whether the tween should be handled in reverse
		@return		Whether the tween should be reversed

		@since 1.0.0
	**/
	public function getReverse():Bool;

	/**
		Smart rotation prevents undesired results when tweening rotation values
		@return		Whether smart rotation should be enabled

		@since 1.0.0
	**/
	public function getSmartRotation():Bool;

	/**
		Snapping causes tween values to be rounded automatically
		@return		Whether tween values should be rounded

		@since 1.0.0
	**/
	public function getSnapping():Bool;

	/**
		A function which will be called when the tween finishes
		@return 	The function to be called

		@since 1.0.0
	**/
	public function getOnComplete():Dynamic;

	/**
		The parameters to pass to the `onComplete` function.
		@return 	Parameters to pass to the handler function when it is called

		@since 1.0.0
	**/
	public function getOnCompleteParams():Array<Dynamic>;

	/**
		A function which will be called when the tween repeats
		@return 	The function to be called

		@since 1.0.0
	**/
	public function getOnRepeat():Dynamic;

	/**
		The parameters to pass to the `onRepeat` function.
		@return 	Parameters to pass to the handler function when it is called

		@since 1.0.0
	**/
	public function getOnRepeatParams():Array<Dynamic>;

	/**
		A function which will be called when the tween updates
		@return 	The function to be called

		@since 1.0.0
	**/
	public function getOnUpdate():Dynamic;

	/**
		The parameters to pass to the `onUpdate` function.
		@return 	Parameters to pass to the handler function when it is called

		@since 1.0.0
	**/
	public function getOnUpdateParams():Array<Dynamic>;

	/**
		A function which will be called when the tween pauses
		@return 	The function to be called

		@since 1.0.0
	**/
	public function getOnPause():Dynamic;

	/**
		The parameters to pass to the `onPause` function.
		@return 	Parameters to pass to the handler function when it is called

		@since 1.0.0
	**/
	public function getOnPauseParams():Array<Dynamic>;

	/**
		A function which will be called when the tween resumes after pausing
		@return 	The function to be called

		@since 1.0.0
	**/
	public function getOnResume():Dynamic;

	/**
		The parameters to pass to the `onResume` function.
		@return 	Parameters to pass to the handler function when it is called

		@since 1.0.0
	**/
	public function getOnResumeParams():Array<Dynamic>;
}
