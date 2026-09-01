import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes the simulated screen taller for the duration of the test.
///
/// The default test surface is 800x600, shorter than any phone. Long pages
/// (the student profile, the job form, the applicant sheet) then keep their
/// bottom half outside the viewport: a ListView never builds those children,
/// and a tap lands outside the render tree. A taller surface reproduces a
/// realistic phone instead of forcing every test to scroll.
///
/// The size is restored automatically once the test ends, so the other tests
/// keep the default surface.
void useTallSurface(
  WidgetTester tester, {
  Size size = const Size(600, 1600),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}