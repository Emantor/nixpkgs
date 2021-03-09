{ lib, wayland, wayland-protocols, xorgserver, xkbcomp, xkeyboard_config
, epoxy, libtirpc, libxslt, libunwind, makeWrapper, egl-wayland, fetchurl, meson, ninja
, pkg-config, fontutil, defaultFontPath ? "" }:

with lib;

xorgserver.overrideAttrs (oldAttrs: {

  name = "xwayland-21.0.99.902";
  src = fetchurl {
    url = "https://xorg.freedesktop.org/archive/individual/xserver/xwayland-21.0.99.902.tar.xz";
    sha256 = "sha256-eZSR3ZnLLG298FFiRB0EaaKps24Il1XrWXKd049Erc4=";
  };
  patches = [ ];
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ meson ninja ];
  buildInputs = oldAttrs.buildInputs ++ [ egl-wayland fontutil libtirpc ];
  propagatedBuildInputs = oldAttrs.propagatedBuildInputs
    ++ [wayland wayland-protocols epoxy libxslt makeWrapper libunwind];
  mesonFlags = [
    "-Dxwayland-eglstream=true"
    "-Ddefault-font-path=${defaultFontPath}"
    "-Dxkb_bin_dir=${xkbcomp}/bin"
    "-Dxkb_dir=${xkeyboard_config}/etc/X11/xkb"
    "-Dxkb_output_dir=$(out)/share/X11/xkb/compiled"
  ];

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
  '';

  meta = {
    description = "An X server for interfacing X11 apps with the Wayland protocol";
    homepage = "https://wayland.freedesktop.org/xserver.html";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
