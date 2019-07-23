import massive.munit.TestSuite;

import feathers.controls.BasicButtonTest;
import feathers.controls.ToggleSwitchTest;
import feathers.core.ComponentLifecycleTest;
import feathers.core.InvalidationTest;
import feathers.core.MinAndMaxDimensionsTest;
import feathers.core.RestrictedStyleTest;
import feathers.core.ScaleTest;
import feathers.layout.MeasurementsTest;
import feathers.style.ClassVariantStyleProviderTest;
import feathers.style.FunctionStyleProviderTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite
{
	public function new()
	{
		super();

		add(feathers.controls.BasicButtonTest);
		add(feathers.controls.ToggleSwitchTest);
		add(feathers.core.ComponentLifecycleTest);
		add(feathers.core.InvalidationTest);
		add(feathers.core.MinAndMaxDimensionsTest);
		add(feathers.core.RestrictedStyleTest);
		add(feathers.core.ScaleTest);
		add(feathers.layout.MeasurementsTest);
		add(feathers.style.ClassVariantStyleProviderTest);
		add(feathers.style.FunctionStyleProviderTest);
	}
}
