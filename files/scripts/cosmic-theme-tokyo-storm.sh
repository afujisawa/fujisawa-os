#!/usr/bin/env bash
# Gera o tema escuro padrão do COSMIC com a paleta Tokyo Night Storm.
# Usa a própria biblioteca do COSMIC (cosmic-theme), na mesma revisão do
# libcosmic usada pelo cosmic-settings 1.11 do Fedora, para calcular o tema
# completo (botões, contêineres, texto) a partir das cores de entrada.
# Saída: /out/cosmic/com.system76.CosmicTheme.Dark{,.Builder}/v2/*
# (copiada depois para /usr/share/cosmic na imagem).
set -oue pipefail

LIBCOSMIC_REV=430f3d48a97d8779f9c1985473912e594ccca1ae # cosmic-settings epoch-1.11.0

mkdir -p /src/tokyo-theme/src
cat > /src/tokyo-theme/Cargo.toml <<EOF
[package]
name = "tokyo-theme"
version = "0.1.0"
edition = "2024"

[dependencies]
cosmic-theme = { git = "https://github.com/pop-os/libcosmic", rev = "${LIBCOSMIC_REV}", default-features = false }
cosmic-config = { git = "https://github.com/pop-os/libcosmic", rev = "${LIBCOSMIC_REV}", default-features = false, features = ["macro"] }
EOF

cat > /src/tokyo-theme/src/main.rs <<'EOF'
use cosmic_config::CosmicConfigEntry;
use cosmic_theme::palette::{Srgb, Srgba};
use cosmic_theme::{Theme, ThemeBuilder};

fn rgb(hex: u32) -> Srgb {
    Srgb::new(
        ((hex >> 16) & 0xff) as f32 / 255.0,
        ((hex >> 8) & 0xff) as f32 / 255.0,
        (hex & 0xff) as f32 / 255.0,
    )
}

fn rgba(hex: u32) -> Srgba {
    let c = rgb(hex);
    Srgba::new(c.red, c.green, c.blue, 1.0)
}

fn main() {
    // Tokyo Night Storm
    let mut builder = ThemeBuilder::dark()
        .bg_color(rgba(0x1f2335))             // bg_dark
        .primary_container_bg(rgba(0x24283b)) // bg
        .text_tint(rgb(0xc0caf5))             // fg
        .neutral_tint(rgb(0x565f89))          // comment
        .accent(rgb(0x7aa2f7))                // blue
        .success(rgb(0x9ece6a))               // green
        .warning(rgb(0xe0af68))               // yellow
        .destructive(rgb(0xf7768e));          // red
    builder.secondary_container_bg = Some(rgba(0x292e42)); // bg_highlight
    builder.window_hint = Some(rgb(0x7aa2f7));             // borda da janela ativa

    let theme = builder.clone().build();

    builder
        .write_entry(&ThemeBuilder::dark_config().expect("config do builder"))
        .expect("gravar builder");
    theme
        .write_entry(&Theme::dark_config().expect("config do tema"))
        .expect("gravar tema");
}
EOF

export XDG_CONFIG_HOME=/out
cargo run --release --manifest-path /src/tokyo-theme/Cargo.toml

# Confere que o tema calculado foi gravado
test -s /out/cosmic/com.system76.CosmicTheme.Dark/v2/accent
test -s /out/cosmic/com.system76.CosmicTheme.Dark.Builder/v2/bg_color
ls /out/cosmic/com.system76.CosmicTheme.Dark/v2 | wc -l
