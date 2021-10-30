
counter=0
max=$1

while [ $counter -lt $max ]
  do
   echo $counter
   counter=`expr $counter + 1`
done
