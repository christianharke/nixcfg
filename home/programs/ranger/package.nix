# https://github.com/realfolk/nix/blob/55a474544508546e70cb229235a3ff024315bd6d/lib/packages/ranger/default.nix

{ lib
, fetchFromGitHub
, writeText
, python3Packages
, file
, less
}:

let

  rifleConf = writeText "rifle.conf" (builtins.readFile ./config/rifle.conf);

in

python3Packages.buildPythonApplication rec {
  pname = "ranger";
  version = "master";
  src = fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "136416c7e2ecc27315fe2354ecadfe09202df7dd";
    hash = "sha256-KPCts1MimDQYljoPR4obkbfFT8gH66c542CMG9UW7O1=";
  };
  LC_ALL = "en_US.UTF-8";
  doCheck = true;

  propagatedBuildInputs = [ file python3Packages.astroid python3Packages.pylint python3Packages.pytest ];
  #++ lib.optionals imagePreviewSupport [ python3Packages.pillow ];

  preConfigure = ''
    #UPSTREAM
    substituteInPlace ranger/__init__.py \
      --replace "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"
    # give file previews out of the box
  '';
}
