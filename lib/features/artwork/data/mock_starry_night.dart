import '../../../core/media/focal.dart';
import '../domain/artwork_content.dart';
import 'mock_catalog.dart';

/// Full editorial content for The Starry Night, as written in the design.
final starryNightContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Cypress Tree',
      x: .13,
      y: .55,
      description:
          'Van Gogh used the dark vertical form of the cypress to create a '
          'visual bridge between the earth and the turbulent sky. In Provence, '
          'cypresses stood beside graveyards — a quiet note of mortality at '
          'the edge of a living night.',
    ),
    ArtworkDetail(
      title: 'The Great Swirl',
      x: .44,
      y: .3,
      description:
          'Two currents seem to meet and coil here. Short, directional '
          'strokes turn the air itself into something you can almost feel '
          'moving across the canvas.',
    ),
    ArtworkDetail(
      title: 'The Crescent Moon',
      x: .88,
      y: .13,
      description:
          'Wrapped in an impossible halo, the moon glows more like a sun. It '
          'was painted from memory and imagination — not from what stood '
          'outside the window.',
    ),
    ArtworkDetail(
      title: 'The Village Steeple',
      x: .57,
      y: .66,
      description:
          'The spire is sharp and northern — more Dutch than Provençal. Many '
          'read it as Van Gogh quietly painting home into a southern French '
          'village.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.3, .4),
      heading: 'A view from behind bars',
      opening:
          'In May 1889, Van Gogh admitted himself to the asylum of '
          'Saint-Paul-de-Mausole in Saint-Rémy. From his east-facing window he '
          'watched the sky before sunrise — but he was only permitted to paint '
          'in his studio, by day.',
      quote:
          'This morning I saw the countryside from my window a long time '
          'before sunrise, with nothing but the morning star.',
      quoteSource: 'Van Gogh, letter to Theo, 1889',
      closing:
          'So the night was rebuilt from memory. The village did not sit where '
          'he placed it, and the cypress was moved closer. What we see is less '
          'a view than a recollection, sharpened by longing.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.45, .25),
      heading: 'Paint as weather',
      opening:
          'Van Gogh laid colour on thickly, in short parallel strokes that '
          'follow the direction of movement — a technique that makes the sky '
          'appear to flow even when the canvas is perfectly still.',
      quote:
          'I often think that the night is more alive and more richly '
          'coloured than the day.',
      quoteSource: 'Van Gogh, letter to Theo, 1888',
      closing:
          'Cobalt and ultramarine are set against chrome yellow. '
          'Complementary colours sit side by side, vibrating where they touch '
          '— the reason the stars seem to pulse.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.12, .6),
      heading: 'Between earth and infinity',
      opening:
          'Some see the painting as a vision of eternity; others, a portrait '
          'of a restless mind. The cypress, reaching from the ground to the '
          'stars, is often read as a bridge between life and death.',
      quote: 'Looking at the stars always makes me dream.',
      quoteSource: 'Van Gogh, letter to Theo, 1888',
      closing:
          'Van Gogh himself thought it a failure. Today it is among the most '
          'recognised images on earth — proof, perhaps, that what an artist '
          'doubts can be what the rest of us need.',
    ),
  ],
  narration: const Narration(
    stop: '041',
    narrator: 'the Curator',
    modes: [
      NarrationMode('Quick', '~ 1 min', 62),
      NarrationMode('Story', '~ 4 min', 248),
      NarrationMode('Deep Dive', '~ 10 min', 612),
    ],
    chapters: [
      NarrationChapter(
        'A window at Saint-Rémy',
        'Imagine the room: an iron bed, a barred window, and beyond it, a '
            'valley still asleep.',
      ),
      NarrationChapter(
        'Painting from memory',
        'He could not paint at night — so he carried the sky with him, and '
            'painted it by daylight.',
      ),
      NarrationChapter(
        'A sky in motion',
        'Follow the strokes with your eyes. They never stop. Neither, he '
            'wrote, did his thoughts.',
      ),
      NarrationChapter(
        'The cypress and the village',
        'Below the storm, the village sleeps. Only the cypress is awake '
            'enough to reach the stars.',
      ),
    ],
  ),
  comparison: ArtworkComparison(
    otherId: ArtworkIds.sunrise,
    title: 'Compare with Monet',
    subtitle: 'Two nights, two ways of seeing',
    facets: [
      _facet(
        'Color',
        (.5, .3),
        (.6, .5),
        'Cobalt and ultramarine against chrome yellow — complementary '
            'contrasts pushed until they vibrate.',
        'Soft greys and blues pierced by one orange sun. Colour as a passing '
            'breath of atmosphere.',
        'Van Gogh makes colour shout. Monet lets a single note carry the '
            'whole morning.',
      ),
      _facet(
        'Composition',
        (.1, .5),
        (.3, .7),
        'A rising cypress and a rolling sky lock the canvas into a strong, '
            'vertical rhythm.',
        'A low horizon and open water. The sun sits off-centre, an '
            'afterthought made central.',
        'One painting climbs. The other spreads out and settles.',
      ),
      _facet(
        'Technique',
        (.45, .25),
        (.7, .4),
        'Thick impasto in short directional strokes — paint handled almost '
            'like sculpture.',
        'Thin, rapid, sketch-like dabs, likely finished in a single sitting.',
        'Weight versus speed: Van Gogh builds, Monet glances.',
      ),
      _facet(
        'Emotion',
        (.88, .15),
        (.55, .45),
        'Turbulent, yearning, ecstatic. The night as an inner state.',
        'Quiet, hazy, contemplative. A morning seen, not felt through.',
        'Monet records light. Van Gogh feels it.',
      ),
      _facet(
        'Context',
        (.6, .7),
        (.2, .6),
        'Saint-Rémy, 1889 — painted inside an asylum, from memory and '
            'imagination.',
        'Le Havre, 1872 — the industrial port of Monet\'s youth, at dawn.',
        'Seventeen years and one revolution in seeing apart.',
      ),
      _facet(
        'Movement',
        (.3, .5),
        (.5, .5),
        'Post-Impressionism: feeling and structure over faithful appearance.',
        'Impressionism — a movement that took its name from this very canvas.',
        'Without Monet\'s sunrise, there is no Starry Night.',
      ),
    ],
  ),
);

ComparisonFacet _facet(
  String label,
  (double, double) a,
  (double, double) b,
  String textA,
  String textB,
  String verdict,
) {
  return ComparisonFacet(
    label: label,
    focusA: focal(a.$1, a.$2),
    focusB: focal(b.$1, b.$2),
    textA: textA,
    textB: textB,
    verdict: verdict,
  );
}
