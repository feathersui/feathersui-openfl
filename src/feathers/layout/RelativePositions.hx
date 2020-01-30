/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	An abstract that accepts a `RelativePosition` or an
	`Array<RelativePosition>`.

	@since 1.0.0
**/
abstract RelativePositions(Array<RelativePosition>) from Array<RelativePosition> to Array<RelativePosition> {
	inline function new(positions:Array<RelativePosition>) {
		this = positions;
	}

	/**
		Converts a `RelativePosition` to an `Array<RelativePosition>`.

		@since 1.0.0
	**/
	@:from
	public static function fromRelativePosition(position:RelativePosition) {
		return new RelativePositions([position]);
	}
}
