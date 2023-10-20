{ pkgs ? import <nixpkgs> {} }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "volcal";
  version = "0.9.4";

  src = /home/callan/git/volctl;

  postPatch = ''
    substituteInPlace volctl/xwrappers.py \
      --replace 'libXfixes.so' "${pkgs.xorg.libXfixes}/lib/libXfixes.so" \
      --replace 'libXfixes.so.3' "${pkgs.xorg.libXfixes}/lib/libXfixes.so.3"
  '';

  preBuild = ''
    export LD_LIBRARY_PATH=${pkgs.libpulseaudio}/lib
  '';

  nativeBuildInputs =  with pkgs; [
    gobject-introspection
    wrapGAppsHook
    pylint
  ];

  propagatedBuildInputs =  with pkgs; [ pango gtk3 ] ++ (with python3Packages; [
    pulsectl
    click
    pycairo
    pygobject3
    pyyaml
  ]);

  # with strictDeps importing "gi.repository.Gtk" fails with "gi.RepositoryError: Typelib file for namespace 'Pango', version '1.0' not found"
  strictDeps = true;

  # no tests included
  doCheck = false;

  pythonImportsCheck = [ "volctl" ];

  preFixup = ''
    glib-compile-schemas ${pkgs.glib.makeSchemaPath "$out" "${pname}-${version}"}
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${pkgs.libpulseaudio}/lib")
  '';
}