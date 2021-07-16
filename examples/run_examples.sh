#!/bin/bash

# set -e
set -o nounset

rm -f *.vtu *.pvtu

origin=$(pwd)
examples_dir=${1-$origin}
declare -i exitcode=0
echo "*** Running examples in $examples_dir ..."
for example in $examples_dir/*.py
do
    if [[ "$example" == *"-mpi.py" ]]
    then
        echo "*** Running parallel example: $example"
        mpiexec -n 2 python -m mpi4py ${example}

        rm -f *.vtu *.pvtu

        echo "*** Running parallel example lazily (with a single rank only): $example"
        python -m mpi4py ${example} --lazy
    else
        echo "*** Running serial example: $example"
        python ${example}
        rm -f *.vtu *.pvtu
        echo "*** Running serial example lazily: $example"
        python ${example} --lazy
    fi
    if [[ $? -eq 0 ]]
    then
        echo "*** Example $example succeeded."
    else
        ((exitcode=exitcode+1))
        echo "*** Example $example failed."
    fi
done
echo "*** Done running examples!"
if [[ $exitcode -eq 0 ]]
then
    echo "*** No errors."
else
    echo "*** Errors detected ($exitcode)."
    exit $exitcode
fi
#rm -f examples/*.vtu
