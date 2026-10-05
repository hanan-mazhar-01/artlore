import '../../../core/media/focal.dart';
import '../domain/artwork_content.dart';
import 'mock_catalog.dart';

/// Editorial content for Wanderer above the Sea of Fog by Caspar David Friedrich.
final wandererContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Silhouette',
      x: .50,
      y: .52,
      description:
          'Seen strictly from behind (Rückenfigur), the lone wanderer invites '
          'the spectator to see nature through his contemplative eyes.',
    ),
    ArtworkDetail(
      title: 'The Sea of Mist',
      x: .45,
      y: .68,
      description:
          'Swirling fog coils around jagged sandstone peaks inspired by the '
          'wild Elbe Sandstone Mountains.',
    ),
    ArtworkDetail(
      title: 'The Far Horizon',
      x: .50,
      y: .30,
      description:
          'Ghostly mountain ridges fade into an ethereal, pale sky, signifying '
          'the boundary between mortal life and the unknowable infinite.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.5, .45),
      heading: 'The summit of Romanticism',
      opening:
          'Painted in Dresden around 1818, this canvas captured the post-Napoleonic '
          'era\'s spiritual yearning for boundless nature and inner solitude.',
      quote:
          'The painter should paint not only what he sees before him, but also what he sees within himself.',
      quoteSource: 'Caspar David Friedrich',
      closing:
          'Friedrich synthesized field sketches from different Bohemian summits '
          'into one sublime, allegorical landscape.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.5, .5),
      heading: 'The Rückenfigur device',
      opening:
          'By concealing the protagonist\'s identity, Friedrich turns him into a universal '
          'stand-in for every human confronting existence.',
      quote:
          'Close your bodily eye, so that you may see your picture first with the spiritual eye.',
      quoteSource: 'Caspar David Friedrich',
      closing:
          'Dark, razor-sharp foreground boulders plunge into pale atmospheric haze, '
          'magnifying the illusion of limitless vertical depth.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .3),
      heading: 'The Sublime encounter',
      opening:
          'Man stands sovereign atop the mountain, yet remains fragile before the vastness '
          'of the cosmos.',
      quote: 'A silent monument to the solitude of the human spirit.',
      quoteSource: 'Romanticism Essays',
      closing:
          'The fog represents the veil between earthly reality and spiritual mystery.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.temeraire,
    title: 'Compare with Turner',
    subtitle: 'Two Romantic contemplations of destiny',
    facets: [
      ComparisonFacet(
        label: 'Mood',
        focusA: focal(.5, .4),
        focusB: focal(.3, .4),
        textA: 'Still, philosophical, introspective solitude in northern mist.',
        textB: 'Fiery, mournful, blazing farewell to the heroic age of sail.',
        verdict: 'German quietude versus British elemental blaze.',
      ),
    ],
  ),
);

/// Editorial content for The Milkmaid by Johannes Vermeer.
final milkmaidContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Stream of Milk',
      x: .42,
      y: .58,
      description:
          'A delicate white trickle suspended in air, painted with meticulous '
          'micro-droplets of impasto that catch the morning light.',
    ),
    ArtworkDetail(
      title: 'The Crusty Bread',
      x: .38,
      y: .66,
      description:
          'Pointillist dabs of thick paint simulate crusty earthenware and freshly '
          'baked bread on the rustic tabletop.',
    ),
    ArtworkDetail(
      title: 'The Foot Warmer',
      x: .82,
      y: .90,
      description:
          'On the floor beside Delft ceramic tiles sits a traditional charcoal warmer, '
          'hinting at domestic comfort and warmth.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.45, .4),
      heading: 'Dignity in everyday labour',
      opening:
          'Created around 1658 in Vermeer\'s Delft workshop, turning humble kitchen '
          'chores into an act of monumental quiet majesty.',
      quote: 'A servant girl pouring milk is elevated to classical solemnity.',
      quoteSource: 'Rijksmuseum Curatorial Archive',
      closing:
          'Vermeer elevates an everyday household maid into a timeless archetype '
          'of mindful presence.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.42, .55),
      heading: 'Optical precision and pointillé',
      opening:
          'Small globules of light (pointillé) glisten on bread, pottery, and the rough '
          'ultramarine apron fabric.',
      quote: 'No master captured the quiet drama of indoor daylight quite like Vermeer.',
      quoteSource: 'Dutch Masters Review',
      closing:
          'The whitewashed plaster wall is marked by nail holes and chipped patches, '
          'celebrated with total, affectionate honesty.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.45, .35),
      heading: 'The sacrament of the present',
      opening:
          'Her absorption in her task is total. Nothing is wasted, nothing is rushed.',
      quote: 'A moment of stillness so profound it feels sacred.',
      quoteSource: 'Delft Masterpieces Anthology',
      closing:
          'The Milkmaid celebrates the quiet nobility found in humble, honest daily routines.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.pearlEarring,
    title: 'Compare with Pearl Earring',
    subtitle: 'Domestic reality vs exotic reverie',
    facets: [
      ComparisonFacet(
        label: 'Subject',
        focusA: focal(.45, .4),
        focusB: focal(.5, .4),
        textA: 'Humble kitchen maid grounded in the physical reality of Delft.',
        textB: 'Ethereal unknown girl turning as if in an eternal dream.',
        verdict: 'Two masterworks celebrating the mystery of the gaze.',
      ),
    ],
  ),
);

/// Editorial content for Impression, Sunrise by Claude Monet.
final sunriseContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Blood-Orange Sun',
      x: .56,
      y: .33,
      description:
          'A pure dab of unblended vermilion glowing against misty blue-grey sky.',
    ),
    ArtworkDetail(
      title: 'The Ghostly Ships',
      x: .72,
      y: .48,
      description:
          'Masts, cranes, and smokestacks of industrial Le Havre emerge from the morning fog.',
    ),
    ArtworkDetail(
      title: 'The Dark Rowboat',
      x: .45,
      y: .75,
      description:
          'Two swift strokes of dark pigment anchor the foreground in the rippling water.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.55, .4),
      heading: 'The canvas that named a revolution',
      opening:
          'Painted in April 1872 from a hotel window in Le Havre, its title gave '
          'hostile critics the word "Impressionism".',
      quote: 'A landscape is only an impression, instantaneous, hence the title.',
      quoteSource: 'Claude Monet, 1898',
      closing:
          'What began as a sneering insult in a satire magazine became the name '
          'of modern art\'s greatest movement.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.55, .35),
      heading: 'Alla prima speed',
      opening:
          'Painted rapidly in a single morning session before the morning mist '
          'dissolved into daylight.',
      quote: 'Try to forget what objects you have before you — merely think of color.',
      quoteSource: 'Claude Monet',
      closing:
          'The sun and its surrounding sky share almost identical photopic luminance, '
          'causing the sun to shimmer when viewed.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .5),
      heading: 'Dawn of a new era',
      opening:
          'Nature and modern industry meet in hazy harmony as France rebuilt following '
          'the Franco-Prussian war.',
      quote: 'The awakening of light over an industrial harbor.',
      quoteSource: 'Impressionist Studies',
      closing:
          'Monet captures not the harbor itself, but the vibration of light striking the retina.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.starryNight,
    title: 'Compare with Van Gogh',
    subtitle: 'Two dawns, two revolutions in color',
    facets: [
      ComparisonFacet(
        label: 'Motion',
        focusA: focal(.5, .5),
        focusB: focal(.44, .3),
        textA: 'Gentle, horizontal water ripples and drifting morning smoke.',
        textB: 'Violent, swirling cosmic vortices turning night into a storm.',
        verdict: 'Monet records atmospheric light. Van Gogh paints inner spirit.',
      ),
    ],
  ),
);

