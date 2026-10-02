import '../../../core/media/focal.dart';
import '../domain/artwork_content.dart';

/// Editorial content for The Great Wave off Kanagawa.
final greatWaveContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'Mount Fuji',
      x: .625,
      y: .68,
      description:
          'Japan\'s most sacred mountain, shrunk to the size of a wave\'s '
          'spray. The eternal peak sits low and calm — briefly at the mercy of '
          'a passing moment.',
    ),
    ArtworkDetail(
      title: 'The Claws of the Wave',
      x: .53,
      y: .32,
      description:
          'The crest breaks into curling fingers of foam that seem to reach '
          'for the boats. Hokusai turns water into something almost animal.',
    ),
    ArtworkDetail(
      title: 'The Oarsmen',
      x: .55,
      y: .86,
      description:
          'Fishermen bow low over their oars, their heads a row of pale dots. '
          'They do not fight the sea; they ride it, as they must every day.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.6, .65),
      heading: 'Thirty-six views of one mountain',
      opening:
          'Hokusai was in his seventies when he began a series of prints '
          'devoted to Mount Fuji. The Great Wave opened the set — printed in '
          'thousands, sold for the price of a bowl of noodles.',
      quote:
          'From the age of six I had a mania for drawing the forms of things.',
      quoteSource: 'Hokusai, postscript, 1834',
      closing:
          'The prints travelled to Europe in the decades that followed and '
          'changed how Monet, Van Gogh and Debussy saw the world.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.4, .3),
      heading: 'A new blue',
      opening:
          'Each colour was carved into its own woodblock and printed in '
          'sequence. The deep blue is Prussian blue — a synthetic pigment, '
          'newly imported, that made the sea look startlingly modern.',
      quote: 'At ninety I shall penetrate the mystery of things.',
      quoteSource: 'Hokusai, postscript, 1834',
      closing:
          'Western perspective pulls Fuji into the distance, while the wave '
          'stays flat and graphic: two ways of seeing on a single sheet.',
    ),
  ],
);
