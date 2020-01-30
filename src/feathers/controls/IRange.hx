/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IUIControl;

/**
	A UI component that displays a range of values from a minimum to a maximum.

	@since 1.0.0
**/
interface IRange extends IUIControl {
	/**
		The current numeric value of the range.

		The following example sets the range of acceptable values:

		```hx
		range.minimum = 0.0;
		range.maximum = 100.0;
		```

		@since 1.0.0
	**/
	public var value(get, set):Float;

	/**
		The minimum numeric value of the range.

		The following example sets the range of acceptable values:

		```hx
		range.minimum = 0.0;
		range.maximum = 100.0;
		```

		@since 1.0.0
	**/
	public var minimum(get, set):Float;

	/**
		The maximum numeric value of the range.

		The following example sets the range of acceptable values and updates
		the current value:

		```hx
		range.minimum = 0.0;
		range.maximum = 100.0;
		range.value = 50.0;
		```

		@since 1.0.0
	**/
	public var maximum(get, set):Float;
}
