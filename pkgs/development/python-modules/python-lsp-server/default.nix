{ autopep8
, buildPythonPackage
, coverage
, fetchFromGitHub
, flake8
, flaky
, isPy27
, jedi
, lib
, matplotlib
, mccabe
, mock
, numpy
, pandas
, pluggy
, # Allow building a limited set of providers, e.g. ["pycodestyle"].
  providers ? ["*"]
, pycodestyle
, pydocstyle
, pyflakes
, pylint
, pyqt5
, pytestCheckHook
, pytestcov
, python-lsp-jsonrpc
, rope
, setuptools
, ujson
, yapf
}:

let
  withProvider = p: builtins.elem "*" providers || builtins.elem p providers;
in

buildPythonPackage rec {
  pname = "python-lsp-server";
  version = "1.0.1";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-server";
    rev = "v${version}";
    sha256 = "sha256-ziOY2M6te2c5rTuAXY43tcOPmQKNIQZEAs/KwAwXqy8=";
  };

  propagatedBuildInputs = [ setuptools jedi pluggy ujson python-lsp-jsonrpc ]
    ++ lib.optional (withProvider "autopep8") autopep8
    ++ lib.optional (withProvider "mccabe") mccabe
    ++ lib.optional (withProvider "pycodestyle") pycodestyle
    ++ lib.optional (withProvider "pydocstyle") pydocstyle
    ++ lib.optional (withProvider "pyflakes") pyflakes
    ++ lib.optional (withProvider "pylint") pylint
    ++ lib.optional (withProvider "rope") rope
    ++ lib.optional (withProvider "yapf") yapf;

  # The tests require all the providers, disable otherwise.
  doCheck = providers == ["*"];

  checkInputs = [
    # Do not propagate flake8 or it will enable pyflakes implicitly
    # already have jedi, which is the preferred option
    # rope is technically a dependency, but we don't add it by default since we
    coverage
    flake8
    flaky
    mock
    pytestCheckHook
    pytestcov
    rope
    numpy
    matplotlib
    pandas
    pyqt5
    coverage
  ];

  dontUseSetuptoolsCheck = true;

  preCheck = ''
    export HOME=$TEMPDIR
  '';


  meta = with lib; {
    homepage = "https://github.com/python-lsp/python-lsp-server";
    description = "A Python 3.6+ implementation of the Language Server Protocol.";
    license = licenses.mit;
    maintainers = [ maintainers.emantor ];
  };
}
