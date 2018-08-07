#!/usr/bin/env bash

set -e

virtual_environment_name=$(basename $(pwd))

export PATH=$HOME/miniconda3/bin:$PATH

echo "Templating environment.yml"
sed s/\{virtual_environment_name\}/$virtual_environment_name/g ./environment.template.yml > environment.yml

if [[ -f $HOME/miniconda3/bin/conda ]]; then # should check for conda on path instead?
  echo "[INFO] OK Found conda!"
  echo "[INFO] Updating conda..."
  conda update -n base conda -y
else
  if [[ ! -f "$HOME/miniconda3_installer/install.sh"  ]]; then
    echo "[INFO] Downloading miniconda installation script..."
    mkdir -p $HOME/miniconda3_installer
    curl "https://repo.anaconda.com/miniconda/Miniconda3-4.5.1-MacOSX-x86_64.sh" -o "$HOME/miniconda3_installer/install.sh"
  fi

  echo "[INFO] Running miniconda installation script..."
  bash "$HOME/miniconda3_installer/install.sh" -u -b -p "$HOME/miniconda3"
fi

if [[ ! -d "$HOME/miniconda3/envs/${virtual_environment_name}" ]]; then
  echo "[INFO] Creating ${virtual_environment_name} virtual environment and installing dependencies..."
  conda env create -f ./environment.yml
else 
  echo "[INFO] Updating dependencies..."
  conda env update # run this only locally to speed up build times
fi

source deactivate
source activate ${virtual_environment_name}
python -m ipykernel install --user --name ${virtual_environment_name} --display-name "${virtual_environment_name}"

echo "[INFO] Done! 🚀 🚀 🚀"
echo '[INFO] To add conda to path, run: export PATH=$HOME/miniconda3/bin:$PATH'
echo "[INFO] To activate the virtual environment, run: source activate ${virtual_environment_name}"
echo "[INFO] To deactivate the virtual environment, run: source deactivate"
