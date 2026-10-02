import 'package:flutter/painting.dart';

import '../../../core/media/art_image_source.dart';
import '../domain/artwork.dart';

/// Stable ids for the mock catalogue.
abstract final class ArtworkIds {
  static const starryNight = 'starry-night';
  static const temeraire = 'fighting-temeraire';
  static const greatWave = 'great-wave';
  static const pearlEarring = 'pearl-earring';
  static const sunrise = 'impression-sunrise';
  static const wanderer = 'wanderer';
  static const kiss = 'the-kiss';
  static const sunflowers = 'sunflowers';
  static const milkmaid = 'milkmaid';
  static const grandeJatte = 'grande-jatte';
}

const _dir = 'assets/artworks';

/// Bundled catalogue used by the mock repositories.
const mockCatalog = <String, Artwork>{
  ArtworkIds.starryNight: Artwork(
    id: ArtworkIds.starryNight,
    title: 'The Starry Night',
    artist: 'Vincent van Gogh',
    artistShort: 'Van Gogh',
    artistLife: '1853–1890',
    year: '1889',
    medium: 'Oil on canvas',
    dimensions: '73.7 × 92.1 cm',
    museum: 'MoMA',
    city: 'New York',
    movement: 'Post-Impressionism',
    summary:
        'Painted from a barred window at the asylum in Saint-Rémy, just before '
        'dawn. The village is invented, the sky is remembered — and the night '
        'is far more alive than any night Van Gogh actually saw.',
    image: ArtImageSource.asset(
      '$_dir/starry_night.jpg',
      aspect: 1.263,
      hdAsset: '$_dir/starry_night_hd.jpg',
    ),
    heroFocus: Alignment(-.3, 0),
  ),
  ArtworkIds.temeraire: Artwork(
    id: ArtworkIds.temeraire,
    title: 'The Fighting Temeraire',
    artist: 'J. M. W. Turner',
    artistShort: 'Turner',
    artistLife: '1775–1851',
    year: '1839',
    medium: 'Oil on canvas',
    dimensions: '90.7 × 121.6 cm',
    museum: 'National Gallery',
    city: 'London',
    movement: 'Romanticism',
    summary:
        'A veteran of Trafalgar is towed upriver to be broken for scrap. '
        'Turner sets the sun down behind her like a farewell — steam and iron '
        'leading the age of sail quietly away.',
    image: ArtImageSource.asset('$_dir/fighting_temeraire.jpg', aspect: 1.346),
  ),
  ArtworkIds.greatWave: Artwork(
    id: ArtworkIds.greatWave,
    title: 'The Great Wave off Kanagawa',
    artist: 'Katsushika Hokusai',
    artistShort: 'Hokusai',
    artistLife: '1760–1849',
    year: 'c. 1831',
    medium: 'Woodblock print',
    dimensions: '25.7 × 37.9 cm',
    museum: 'The Met',
    city: 'New York',
    movement: 'Ukiyo-e',
    summary:
        'A colossal wave curls like a claw over three fragile boats, while '
        'Mount Fuji sits small and still in the distance — eternal, and for '
        'one moment, at the mercy of the sea.',
    image: ArtImageSource.asset('$_dir/great_wave.jpg', aspect: 1.488),
  ),
  ArtworkIds.pearlEarring: Artwork(
    id: ArtworkIds.pearlEarring,
    title: 'Girl with a Pearl Earring',
    artist: 'Johannes Vermeer',
    artistShort: 'Vermeer',
    artistLife: '1632–1675',
    year: 'c. 1665',
    medium: 'Oil on canvas',
    dimensions: '44.5 × 39 cm',
    museum: 'Mauritshuis',
    city: 'The Hague',
    movement: 'Dutch Golden Age',
    summary:
        'Not a portrait but a tronie — a study of a face, a turban, a glance. '
        'She has no name, and that is why she stays with us: she turns as if '
        'we had only just spoken.',
    image: ArtImageSource.asset('$_dir/pearl_earring.jpg', aspect: .844),
    heroFocus: Alignment(0, -.4),
  ),
  ArtworkIds.sunrise: Artwork(
    id: ArtworkIds.sunrise,
    title: 'Impression, Sunrise',
    artist: 'Claude Monet',
    artistShort: 'Monet',
    artistLife: '1840–1926',
    year: '1872',
    medium: 'Oil on canvas',
    dimensions: '48 × 63 cm',
    museum: 'Musée Marmottan Monet',
    city: 'Paris',
    movement: 'Impressionism',
    summary:
        'The port of Le Havre dissolves into mist around a single orange sun. '
        'A critic mocked the title — and in doing so named an entire movement.',
    image: ArtImageSource.asset('$_dir/impression_sunrise.jpg', aspect: 1.289),
  ),
  ArtworkIds.wanderer: Artwork(
    id: ArtworkIds.wanderer,
    title: 'Wanderer above the Sea of Fog',
    artist: 'Caspar David Friedrich',
    artistShort: 'Friedrich',
    artistLife: '1774–1840',
    year: '1818',
    medium: 'Oil on canvas',
    dimensions: '94.8 × 74.8 cm',
    museum: 'Hamburger Kunsthalle',
    city: 'Hamburg',
    movement: 'Romanticism',
    summary:
        'A lone figure stands with his back to us above a sea of fog. We never '
        'see his face — so we stand where he stands, and the view becomes ours.',
    image: ArtImageSource.asset('$_dir/wanderer.jpg', aspect: .781),
    heroFocus: Alignment(0, -.4),
  ),
  ArtworkIds.kiss: Artwork(
    id: ArtworkIds.kiss,
    title: 'The Kiss',
    artist: 'Gustav Klimt',
    artistShort: 'Klimt',
    artistLife: '1862–1918',
    year: '1908',
    medium: 'Oil and gold leaf on canvas',
    dimensions: '180 × 180 cm',
    museum: 'Belvedere',
    city: 'Vienna',
    movement: 'Art Nouveau',
    summary:
        'Two lovers dissolve into a single robe of gold at the edge of a '
        'flowered cliff. Klimt borrowed the shimmer from Byzantine mosaics and '
        'made it tender.',
    image: ArtImageSource.asset('$_dir/the_kiss.jpg', aspect: .997),
  ),
  ArtworkIds.sunflowers: Artwork(
    id: ArtworkIds.sunflowers,
    title: 'Sunflowers',
    artist: 'Vincent van Gogh',
    artistShort: 'Van Gogh',
    artistLife: '1853–1890',
    year: '1888',
    medium: 'Oil on canvas',
    dimensions: '92.1 × 73 cm',
    museum: 'National Gallery',
    city: 'London',
    movement: 'Post-Impressionism',
    summary:
        'Painted to welcome Gauguin to Arles, the flowers pass from bloom to '
        'seed in a single vase — yellow on yellow, a whole life in one colour.',
    image: ArtImageSource.asset('$_dir/sunflowers.jpg', aspect: .793),
  ),
  ArtworkIds.milkmaid: Artwork(
    id: ArtworkIds.milkmaid,
    title: 'The Milkmaid',
    artist: 'Johannes Vermeer',
    artistShort: 'Vermeer',
    artistLife: '1632–1675',
    year: 'c. 1658',
    medium: 'Oil on canvas',
    dimensions: '45.5 × 41 cm',
    museum: 'Rijksmuseum',
    city: 'Amsterdam',
    movement: 'Dutch Golden Age',
    summary:
        'A thin stream of milk, a still room, light from the left. Vermeer '
        'turns a kitchen task into something close to devotion.',
    image: ArtImageSource.asset('$_dir/milkmaid.jpg', aspect: .892),
  ),
  ArtworkIds.grandeJatte: Artwork(
    id: ArtworkIds.grandeJatte,
    title: 'A Sunday on La Grande Jatte',
    artist: 'Georges Seurat',
    artistShort: 'Seurat',
    artistLife: '1859–1891',
    year: '1884',
    medium: 'Oil on canvas',
    dimensions: '207.5 × 308.1 cm',
    museum: 'Art Institute',
    city: 'Chicago',
    movement: 'Post-Impressionism',
    summary:
        'Thousands of dots of pure colour, set side by side, only mix in your '
        'eye. A lazy Sunday afternoon, built as patiently as a cathedral.',
    image: ArtImageSource.asset('$_dir/grande_jatte.jpg', aspect: 1.502),
  ),
};
