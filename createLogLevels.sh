#!/bin/bash

for last in "$@"; do :; done

echo Writing LogUnit.bsv file...

echo "package LogUnit;" > src/LogUnit.bsv
echo "typedef enum {" >> src/LogUnit.bsv
for var in "$@"
do
    unit=${var^^}
    echo Adding LogUnit $unit...
    if [ "$last" = "$var" ]; then
        echo "  $unit" >> src/LogUnit.bsv
    else
        echo "  $unit," >> src/LogUnit.bsv
    fi
done
echo "} LogUnit deriving (Eq,Bits,FShow);" >> src/LogUnit.bsv

echo "function String logUnitToString(LogUnit unit);" >> src/LogUnit.bsv
echo "  return case (unit) matches" >> src/LogUnit.bsv
for var in "$@"
do
    unit=${var^^}
    echo "      $unit: \"$unit\";" >> src/LogUnit.bsv
done
echo "  endcase;" >> src/LogUnit.bsv
echo "endfunction" >> src/LogUnit.bsv

echo "endpackage" >> src/LogUnit.bsv

echo Wrote LogUnit.bsv file


echo Writing BlueLogging.mk file...

echo "ifneq (\$(LOG),)" > BlueLogging.mk
echo "RUN_FLAGS+=+LOG=\${LOG}" >> BlueLogging.mk
echo "endif" >> BlueLogging.mk

for var in "$@"
do
    unit=${var^^}
    echo "ifneq (\$(LOG_$unit),)" >> BlueLogging.mk
    echo "RUN_FLAGS+=+LOG_$unit=\${LOG_$unit}" >> BlueLogging.mk
    echo "endif" >> BlueLogging.mk
done

echo Wrote BlueLogging.mk file