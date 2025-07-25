{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "wayback-machine-archiver";
  version = "1.9.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "agude";
    repo = "wayback-machine-archiver";
    rev = "v${version}";
    sha256 = "0dnnqx507gpj8wsx6f2ivfmha969ydayiqsvxh23p9qcixw9257x";
  };

  build-system = with python3.pkgs; [
    setuptools
    pypandoc
  ];

  dependencies = with python3.pkgs; [ requests ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    requests-mock
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \"pytest-runner\", ""
  '';

  pythonImportsCheck = [ "wayback_machine_archiver" ];

  meta = with lib; {
    description = "Python script to submit web pages to the Wayback Machine for archiving";
    homepage = "https://github.com/agude/wayback-machine-archiver";
    license = licenses.mit;
    maintainers = with maintainers; [ dandellion ];
    mainProgram = "archiver";
  };
}
