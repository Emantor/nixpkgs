{ buildPythonPackage
, fetchFromGitHub
, lib
, coverage
, isPy27
, pycodestyle
, pyflakes
, pylint
, pytestcov
, pytestCheckHook
, setuptools
, ujson
}:

buildPythonPackage rec {
  pname = "python-lsp-jsonrpc";
  version = "1.0.0";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-jsonrpc";
    rev = "v${version}";
    sha256 = "sha256-ETQY9hGUK8NVPJi/9uEn2Q6s068qlS3ABZV1RTTSi0A=";
  };

  propagatedBuildInputs = [ setuptools ujson ];

  checkInputs = [
    coverage
    pycodestyle
    pyflakes
    pytestcov
    pytestCheckHook
    pylint
  ];

  dontUseSetuptoolsCheck = true;

  meta = with lib; {
    homepage = "https://github.com/python-lsp/python-lsp-jsonrpc";
    description = "A Python 3.6+ server implementation of the JSON RPC 2.0 protocol.";
    license = licenses.mit;
    maintainers = [ maintainers.emantor ];
  };
}
