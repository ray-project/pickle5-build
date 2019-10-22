#!/bin/bash

set -x

# Cause the script to exit if a single command fails.
set -e

cat << EOF > "/usr/bin/nproc"
#!/bin/bash
echo 10
EOF
chmod +x /usr/bin/nproc

PYTHONS=("cp35-cp35m"
         "cp36-cp36m"
         "cp37-cp37m")

# The minimum supported numpy version is 1.14, see
# https://issues.apache.org/jira/browse/ARROW-3141
NUMPY_VERSIONS=("1.14.5"
                "1.14.5"
                "1.14.5")

# Remove this old Python 2.4.3 executable, and make the "python2" command find
# a newer version of Python. We need this for autogenerating some files for the
# UI.
rm -f /usr/bin/python2
ln -s /opt/python/cp27-cp27m/bin/python2 /usr/bin/python2

mkdir .whl
for ((i=0; i<${#PYTHONS[@]}; ++i)); do
  PYTHON=${PYTHONS[i]}
  NUMPY_VERSION=${NUMPY_VERSIONS[i]}

  pushd pickle5-backport
    # Fix the numpy version because this will be the oldest numpy version we can
    # support.
    /opt/python/${PYTHON}/bin/pip install -q numpy==${NUMPY_VERSION} cython==0.29.0
    PATH=/opt/python/${PYTHON}/bin:$PATH /opt/python/${PYTHON}/bin/python setup.py bdist_wheel
    # In the future, run auditwheel here.
    mv dist/*.whl ../.whl/
  popd
done
