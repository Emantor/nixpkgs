{
  ansicolors,
  attrs,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch,
  grpcio,
  grpcio-tools,
  grpcio-reflection,
  jinja2,
  lib,
  nix-update-script,
  mock,
  openssh,
  pexpect,
  psutil,
  pyserial,
  pytestCheckHook,
  pytest-benchmark,
  pytest-dependency,
  pytest-mock,
  pyudev,
  pyusb,
  pyyaml,
  requests,
  setuptools,
  setuptools-scm,
  xmodem,
}:

buildPythonPackage rec {
  pname = "labgrid";
  version = "25.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "labgrid-project";
    repo = "labgrid";
    tag = "v${version}";
    hash = "sha256-cLofkkp2T6Y9nQ5LIS7w9URZlt8DQNN8dm3NnrvcKWY=";
  };

  passthru.updateScript = nix-update-script { };

  # Remove after package bump
  patches = [
    (fetchpatch {
      url = "https://github.com/Emantor/labgrid/commit/4a66b43882811d50600e37aa39b24ec40398d184.patch";
      sha256 = "sha256-eJMB1qFWiDzQXEB4dYOHYMQqCPHXEWCwWjNNY0yTC2s=";
    })
    (fetchpatch {
      url = "https://github.com/Emantor/labgrid/commit/d9933b3ec444c35d98fd41685481ecae8ff28bf4.patch";
      sha256 = "sha256-Zx5j+CD6Q89dLmTl5QSKI9M1IcZ97OCjEWtEbG+CKWE=";
    })
    (fetchpatch {
      url = "https://github.com/Emantor/labgrid/commit/f0b672afe1e8976c257f0adff9bf6e7ee9760d6f.patch";
      sha256 = "sha256-M7rg+W9SjWDdViWyWe3ERzbUowxzf09c4w1yG3jQGak=";
    })
    (fetchpatch {
      url = "https://github.com/labgrid-project/labgrid/commit/bc6de2e0ca3248d3bf2690d5ce3c0e32518840c6.patch";
      sha256 = "sha256-bygWtmQXzl97MFED9Iz14ALdwcU33ivMEL/XryT78bo=";
    })
    (fetchpatch {
      url = "https://github.com/labgrid-project/labgrid/commit/18646f748892988f63ea4d95be32c669c68c2d2b.patch";
      sha256 = "sha256-cZq1nufGgG9PDw+slc5+GqHcUZLFyWoTPkjRzHDp2K0=";
    })
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    ansicolors
    attrs
    jinja2
    grpcio
    grpcio-tools
    grpcio-reflection
    pexpect
    pyserial
    pyudev
    pyusb
    pyyaml
    requests
    xmodem
  ];

  pythonRemoveDeps = [ "pyserial-labgrid" ];

  pythonImportsCheck = [ "labgrid" ];

  nativeCheckInputs = [
    mock
    openssh
    psutil
    pytestCheckHook
    pytest-benchmark
    pytest-mock
    pytest-dependency
  ];

  disabledTests = [
    # flaky, timing sensitive
    "test_timing"

    # flaky, depends on ssh connection
    "test_argument_device_expansion"
    "test_argument_file_expansion"
    "test_local_managedfile"
  ];

  pytestFlags = [ "--benchmark-disable" ];

  meta = {
    description = "Embedded control & testing library";
    homepage = "https://github.com/labgrid-project/labgrid";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux;
  };
}
