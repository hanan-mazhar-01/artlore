import '../../../core/media/focal.dart';
import '../domain/artwork_content.dart';
import 'mock_catalog.dart';

/// Editorial content for Girl with a Pearl Earring.
final pearlEarringContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Pearl',
      x: .44,
      y: .65,
      description:
          'A single drop of lead-white paint creates the illusion of an opulent '
          'teardrop pearl — yet there is no hook holding it to her ear.',
    ),
    ArtworkDetail(
      title: 'The Turban',
      x: .52,
      y: .28,
      description:
          'Wrapped in ultramarine and yellow silk, this headdress marked '
          'the painting as a tronie — an exotic character study rather than a portrait.',
    ),
    ArtworkDetail(
      title: 'The Parted Lips',
      x: .54,
      y: .72,
      description:
          'Glistening with moisture, her parted lips suggest an intake of breath, '
          'capturing a fleeting, intimate moment frozen in time.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.5, .4),
      heading: 'The Master of Delft',
      opening:
          'Painted around 1665 in Delft, this enigmatic canvas was sold for a mere '
          'two guilders after Vermeer\'s death and rediscovered centuries later.',
      quote:
          'She turns as if caught between stepping into the room and turning away forever.',
      quoteSource: 'Mauritshuis Collection Archive',
      closing:
          'Vermeer left no diaries and fewer than forty paintings, leaving the '
          'identity of his most famous subject an enduring mystery.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.44, .65),
      heading: 'Liquid light on lapis lazuli',
      opening:
          'Vermeer ground real lapis lazuli into natural ultramarine — an extravagantly '
          'expensive pigment that bankrupted him but gives the turban its immortal brilliance.',
      quote: 'Vermeer paints not things, but the light that strikes them.',
      quoteSource: 'Thoré-Bürger, French art critic, 1866',
      closing:
          'Soft glazes and blended contours dissolve edges, making her skin appear '
          'to radiate soft northern daylight.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .5),
      heading: 'The Dutch Mona Lisa',
      opening:
          'Unlike traditional portraits commissioned by wealthy patrons, tronies were '
          'painted for the open art market to showcase expressive character.',
      quote: 'An innocent glance that carries the weight of unspoken centuries.',
      quoteSource: 'Johannes Vermeer Monograph',
      closing:
          'Her gaze is direct yet guarded, confronting the viewer with timeless vulnerability.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.milkmaid,
    title: 'Compare with The Milkmaid',
    subtitle: 'Two faces of Dutch Golden Age grace',
    facets: [
      ComparisonFacet(
        label: 'Light',
        focusA: focal(.44, .65),
        focusB: focal(.42, .58),
        textA: 'Diffused, mysterious, set against deep black darkness.',
        textB: 'Crisp morning daylight streaming through leaded glass.',
        verdict: 'Vermeer turns light into an emotional presence.',
      ),
      ComparisonFacet(
        label: 'Subject',
        focusA: focal(.5, .4),
        focusB: focal(.45, .4),
        textA: 'An imaginary exotic tronie in silk and pearls.',
        textB: 'A kitchen maid absorbed in daily household routine.',
        verdict: 'The sacred hidden inside the everyday.',
      ),
    ],
  ),
);

/// Editorial content for The Kiss by Gustav Klimt.
final kissContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Golden Mantle',
      x: .50,
      y: .55,
      description:
          'Rectangles on the man, circles and blossoms on the woman — Klimt encodes '
          'masculine and feminine energies into geometric ornament.',
    ),
    ArtworkDetail(
      title: 'The Precipice',
      x: .60,
      y: .88,
      description:
          'The lovers kneel on a cliff carpeted in wild flowers, suspended between '
          'ecstasy and an abyss.',
    ),
    ArtworkDetail(
      title: 'The Golden Aura',
      x: .48,
      y: .35,
      description:
          'Layered gold leaf, bronze paint, and silver flakes evoke the sacred halo '
          'of Byzantine mosaics.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.5, .35),
      heading: 'Vienna\'s golden secession',
      opening:
          'Unveiled at the 1908 Kunstschau in Vienna, The Kiss was purchased immediately '
          'by the Austrian State before the exhibition even closed.',
      quote: 'All art is erotic.',
      quoteSource: 'Gustav Klimt, 1907',
      closing:
          'At the twilight of the Austro-Hungarian Empire, Klimt crafted an eternal '
          'monument to romantic transcendence.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.5, .5),
      heading: 'Gilding the canvas',
      opening:
          'Inspired by 6th-century Ravenna mosaics, Klimt applied genuine gold leaf '
          'over oil glazes to create a shimmering jewel box of texture.',
      quote: 'Whoever wants to know something about me should look attentively at my pictures.',
      quoteSource: 'Gustav Klimt, Commentary',
      closing:
          'Flat decorative patterns contrast with three-dimensionally rendered faces, '
          'blending realism and symbolist ornament.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.48, .32),
      heading: 'Sacred embrace at the edge',
      opening:
          'The lovers are enveloped in an unbroken cocoon of gold, secluded from '
          'the chaos of the outer world.',
      quote: 'A timeless hymn to love standing firm against modern alienation.',
      quoteSource: 'Belvedere Museum Anthology',
      closing:
          'Klimt elevates human desire into a universal spiritual communion.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.starryNight,
    title: 'Compare with Van Gogh',
    subtitle: 'Golden ecstasy vs cosmic turbulence',
    facets: [
      ComparisonFacet(
        label: 'Surface',
        focusA: focal(.5, .5),
        focusB: focal(.44, .3),
        textA: 'Flawless gold leaf, delicate silver filigree, and floral mosaics.',
        textB: 'Thick, churning sculptural impasto straight from the paint tube.',
        verdict: 'Vienna luxury versus Provençal raw agony.',
      ),
    ],
  ),
);

/// Editorial content for Sunflowers by Vincent van Gogh.
final sunflowersContent = ArtworkContent(
  details: const [
    ArtworkDetail(
      title: 'The Heavy Seed Heads',
      x: .52,
      y: .45,
      description:
          'Thick sculptural impasto builds seeds you can almost touch with your fingertips.',
    ),
    ArtworkDetail(
      title: 'The Yellow Harmony',
      x: .48,
      y: .70,
      description:
          'Chrome yellow across table, vase, and petals creates a revolutionary '
          'symphony in one single radiant hue.',
    ),
    ArtworkDetail(
      title: 'The Drooping Petal',
      x: .35,
      y: .55,
      description:
          'From bursting buds to wilting stems, Van Gogh chronicles the entire cycle '
          'of life and decay in fourteen blooms.',
    ),
  ],
  story: [
    StoryChapter(
      label: 'History',
      focus: focal(.5, .4),
      heading: 'A welcome for Gauguin',
      opening:
          'Painted in Arles in August 1888 to decorate the guest bedroom of Paul Gauguin '
          'in the Yellow House before their shared artistic retreat.',
      quote: 'The sunflower is mine, in a way.',
      quoteSource: 'Van Gogh, letter to Theo, 1889',
      closing:
          'Van Gogh saw the sunflower as a symbol of southern sunshine and gratitude, '
          'painted during a burst of feverish optimism.',
    ),
    StoryChapter(
      label: 'Technique',
      focus: focal(.5, .5),
      heading: 'The power of yellow',
      opening:
          'Van Gogh utilized newly invented chrome yellow pigments, applying paint '
          'thickly with palette knives to sculpt petals into physical relief.',
      quote: 'To attain the high yellow note that I attained last summer.',
      quoteSource: 'Van Gogh, letter to Theo',
      closing:
          'The sculpted relief catches ambient light, causing the textured blooms to '
          'shift in brilliance as the viewer moves.',
    ),
    StoryChapter(
      label: 'Interpretation',
      focus: focal(.5, .6),
      heading: 'Gratitude in bloom',
      opening:
          'Rather than a conventional still life, the sunflowers represent devotion, '
          'vitality, and the cycles of human existence.',
      quote: 'How lovely yellow is! It stands for the sun.',
      quoteSource: 'Van Gogh, letter to Emile Bernard',
      closing:
          'Each blossom possesses its own distinct personality — proud, bent, bursting, or serene.',
    ),
  ],
  comparison: ArtworkComparison(
    otherId: ArtworkIds.starryNight,
    title: 'Compare with The Starry Night',
    subtitle: 'Daylight gratitude vs midnight turbulence',
    facets: [
      ComparisonFacet(
        label: 'Palette',
        focusA: focal(.5, .5),
        focusB: focal(.44, .3),
        textA: 'Blinding southern chrome yellow and ochre warmth.',
        textB: 'Deep cobalt, ultramarine, and midnight blues.',
        verdict: 'The two emotional poles of Van Gogh\'s genius.',
      ),
    ],
  ),
);
