import 'package:flutter/foundation.dart';

/// One page of the arrival story.
@immutable
class OnboardingSlide {
  const OnboardingSlide(this.headline, this.subline);

  final String headline;
  final String subline;
}

const onboardingSlides = [
  OnboardingSlide(
    'Every painting has a story.',
    'Discover the stories hiding inside the world\'s greatest artworks.',
  ),
  OnboardingSlide(
    'Point. Scan. Discover.',
    'Use your camera to identify and explore any artwork in seconds.',
  ),
  OnboardingSlide(
    'Look closer.',
    'Symbols, techniques and hidden meanings — revealed one detail at a time.',
  ),
  OnboardingSlide(
    'Build your personal art world.',
    'Save artworks, follow artists and hang your own galleries.',
  ),
];
