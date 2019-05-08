import massive.munit.TestSuite;

import feathers.core.ComponentLifecycleTest;
import feathers.core.InvalidationTest;
import feathers.core.MinAndMaxDimensionsTest;
import feathers.core.RestrictedStyleTest;
import feathers.core.ScaleTest;
import feathers.style.CallbackStyleProviderTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
	public function new()
	{
		super();

		add(feathers.core.ComponentLifecycleTest);
		add(feathers.core.InvalidationTest);
		add(feathers.core.MinAndMaxDimensionsTest);
		add(feathers.core.RestrictedStyleTest);
		add(feathers.core.ScaleTest);
		add(feathers.style.CallbackStyleProviderTest);
	}
}
