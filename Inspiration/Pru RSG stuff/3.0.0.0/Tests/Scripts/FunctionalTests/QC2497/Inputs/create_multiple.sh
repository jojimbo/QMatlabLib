#!/bin.ksh

i=1
while [ $i -le 2000 ];do
file1=GBP_NYC_test_$i.xml
cp GBP_NYC_test.xml $file1

chmod 777 $file1

sed -e s!"GBP_NYC"!"GBP_NYC_$i"!g $file1 > inp.tmp
sed -e s!"All"!"All_$i"!g inp.tmp > inp2.tmp

mv inp2.tmp $file1
rm inp.tmp

i=$(( $i + 1 ))
done

echo "2000 files copied"
