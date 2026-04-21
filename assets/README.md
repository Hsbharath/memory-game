# Assets

## Expected structure

```
assets/
  audio/
    music/
      main_menu_theme.ogg
      africa_theme.ogg
      asia_theme.ogg
      europe_theme.ogg
      north_america_theme.ogg
      south_america_theme.ogg
      australia_theme.ogg
      antarctica_theme.ogg
    sfx/
      card_flip.ogg
      match.ogg
      mismatch.ogg
      victory.ogg
      unlock.ogg
      hint.ogg
      button_click.ogg
  images/
    ui/
      icon.png          (app icon 256x256)
    card_backs/
      africa_back.png
      asia_back.png
      europe_back.png
      north_america_back.png
      south_america_back.png
      australia_back.png
      antarctica_back.png
    continents/
      africa/           (40 card images, 256x256 PNG)
      asia/
      europe/
      north_america/
      south_america/
      australia/
      antarctica/
  fonts/
    (optional custom font files)
```

## Image spec
- Card faces: 256x256 PNG, flat illustration style, clear subject on solid/simple background
- Card backs: 256x256 PNG, continent-themed pattern
- Background art: 1280x720 PNG

## Audio spec
- Music: OGG Vorbis, looping, ~2-4 min per track
- SFX: OGG Vorbis, short clips under 2 seconds
