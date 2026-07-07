// lib/core/theme/google_fonts_catalog.dart

/// Curated list of ~50 popular Google Fonts family names shown in the
/// font-selection bottom sheet.
///
/// `google_fonts` ships 1400+ families — listing all of them would make
/// the bottom sheet unusably long and force loading/caching a huge
/// number of fonts. This curated subset spans serif, sans-serif,
/// handwriting, monospace, and display categories so users still get a
/// genuinely wide variety of choices. Family names must exactly match
/// `GoogleFonts.<family>()` accessor names (PascalCase-to-space
/// conversion handled by `GoogleFonts.getFont`).
class GoogleFontsCatalog {
  GoogleFontsCatalog._();

  static const List<String> families = [
    // Sans-serif
    'Poppins',
    'Roboto',
    'Inter',
    'Nunito',
    'Quicksand',
    'Montserrat',
    'Lato',
    'Mulish',
    'Rubik',
    'Karla',
    'Work Sans',
    'Manrope',
    'Josefin Sans',
    'Raleway',
    'Sora',
    'DM Sans',
    'Outfit',
    'Urbanist',
    'Plus Jakarta Sans',
    'Figtree',

    // Serif
    'Merriweather',
    'Lora',
    'Playfair Display',
    'PT Serif',
    'Bitter',
    'Cormorant Garamond',
    'Libre Baskerville',
    'Crimson Pro',
    'EB Garamond',
    'Source Serif Pro',

    // Handwriting / script
    'Caveat',
    'Dancing Script',
    'Pacifico',
    'Sacramento',
    'Satisfy',
    'Kalam',
    'Shadows Into Light',
    'Great Vibes',
    'Indie Flower',

    // Display
    'Comfortaa',
    'Righteous',
    'Baloo 2',
    'Fredoka',
    'Bungee',
    'Alfa Slab One',
    'Abril Fatface',

    // Monospace
    'JetBrains Mono',
    'Roboto Mono',
    'Space Mono',
    'IBM Plex Mono',

    // Rounded / friendly
    'Varela Round',
  ];
}
