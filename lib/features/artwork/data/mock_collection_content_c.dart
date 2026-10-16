import '../../../core/media/focal.dart';
import '../domain/artwork_content.dart';

/// Editorial content for The Fighting Temeraire by J. M. W. Turner.
final temeraireContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Ghostly Warship',
      x: .32,
      y: .42,
      description: 'The heroic veteran of Trafalgar glides pale and majestic like a spectre.',
    ),
    ArtworkDetail(
      title: 'The Steam Tug',
      x: .40,
      y: .52,
      description: 'Black, squat, and churning thick smoke, representing the relentless dawn of the Industrial Age.',
    ),
    ArtworkDetail(
      title: 'The Blazing Sunset',
      x: .78,
      y: .38,
      description: 'Turner ignites the Thames in radiant gold and crimson, bidding farewell to the age of sail.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.4, .45),
      heading: 'The end of the age of sail',
      opening:
          'Painted in 1838, Turner witnessed the 98-gun HMS Temeraire being towed '
          'up the Thames to be dismantled for scrap timber.',
      quote:
          'The flag that braved the battle and the breeze, no longer owns her.',
      quoteSource: 'J. M. W. Turner, Royal Academy catalogue',
      closing:
          'Turner refused to sell the painting at any price, leaving his "Darling" '
          'to the British nation.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.7, .4),
      heading: 'Painting with fire',
      opening:
          'Turner layered translucent washes and impasto glazes using palette knives '
          'and his thumb to blend the fiery sunset.',
      quote: 'Turner is the father of modern art.',
      quoteSource: 'John Ruskin, Modern Painters',
      closing:
          'The contrast between the ghostly pale ship and the sooty dark tug creates '
          'unforgettable poetic resonance.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .5),
      heading: 'Elegiac farewell to heroism',
      opening:
          'A nation bids farewell to military triumph as steam and machinery '
          'replace wind and wood.',
      quote: 'An elegy for an era passing into memory.',
      quoteSource: 'National Gallery Monographs',
      closing: 'The dying sun sets behind the warship, aligning human history with the cycles of cosmic nature.',
    ),
  ],
);

/// Editorial content for A Sunday on La Grande Jatte by Georges Seurat.
final grandeJatteContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Lady with the Monkey',
      x: .85,
      y: .62,
      description: 'A fashionable Parisian lady holds a pug and a monkey on a leash, an emblem of luxury and wit.',
    ),
    ArtworkDetail(
      title: 'The Reclining Man',
      x: .18,
      y: .75,
      description: 'A sleeveless worker reclines with a pipe, seated in harmony beside bourgeois strollers.',
    ),
    ArtworkDetail(
      title: 'The Stippled Light',
      x: .52,
      y: .45,
      description:
          'Sunlight filters through trees in pure chromatic optical mixtures.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.5, .5),
      heading: 'The birth of Pointillism',
      opening: 'Painted between 1884 and 1886 on an island in the Seine, launching the Neo-Impressionist movement.',
      quote: 'They see poetry in what I have done. No, I apply my method and that is all there is to it.',
      quoteSource: 'Georges Seurat',
      closing: 'Seurat spent two years making over sixty preparatory sketches before completing this monumental mural.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.5, .5),
      heading: 'The optical mixture',
      opening:
          'Instead of mixing paint on a palette, Seurat applied millions of tiny dots '
          'of pure complementary color.',
      quote: 'Color is made of light, and light must be recreated on the eye.',
      quoteSource: 'Divisionism Manifesto',
      closing: 'The viewer\'s eye optically blends adjacent dots, generating luminous vibration.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .4),
      heading: 'A modern Parthenon',
      opening: 'Parisians of all social classes pause in silence, arranged like a classical Greek frieze.',
      quote: 'A silent cathedral of modern leisure.',
      quoteSource: 'Art Institute of Chicago Monographs',
      closing: 'Seurat turns fleeting leisure on an afternoon river island into an eternal monument of order and peace.',
    ),
  ],
);
