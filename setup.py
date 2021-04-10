
import os

import sys, os.path, platform, warnings

from distutils import log
from distutils.core import setup, Command

VERSION = "0.0.1"
AUTHOR = "Author TBD"
AUTHOR_EMAIL = "Author Email TBD"
DESCRIPTION = "Description TBD"
LICENSE = "Apache 2.0"
URL = "https://github.com/TBD"

if os.path.exists("etc/ivpm.info"):
    with open("etc/ivpm.info") as fp:
        for line in fp:
            if line.find("version=") != -1:
                VERSION = line[line.find("=")+1:].strip()
                break

if VERSION is None:
    raise Exception("Error: null version")

if "BUILD_NUM" in os.environ:
    VERSION += "." + os.environ["BUILD_NUM"]

try:
    from wheel.bdist_wheel import bdist_wheel
except ImportError:
    bdist_wheel = None

cmdclass = {
}
if bdist_wheel:
    cmdclass['bdist_wheel'] = bdist_wheel

setup(
  name = "pybfms_spi",
  version=VERSION,
  packages=['spi_bfms'],
  package_dir = {'' : 'src'},
  package_data = {'spi_bfms': ['hdl/*.v']},
  author = AUTHOR,
  author_email = AUTHOR_EMAIL,
  description = DESCRIPTION,
  license = LICENSE,
  keywords = ["SystemVerilog", "Verilog", "RTL", "cocotb"],
  url = URL,
  setup_requires=[
    'setuptools_scm',
  ],
  cmdclass=cmdclass,
  install_requires=[
    'cocotb',
    'pybfms'
  ],
)

