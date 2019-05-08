import massive.munit.TestSuite;

import feathers.core.ComponentLifecycleTest;
import feathers.core.InvalidationTest;
import feathers.core.MinAndMaxDimensionsTest;

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
	}
}
