#http://www.sparrow-framework.org/2010/06/sound-on-ios-best-practices/
for dir in "media/sound"
do
  pushd .

  echo "processing $dir"

  cd "$dir"

  rm -rf *.caf

  for i in *.wav; do
    # creates .caf (IMA4 compression, MONO)
    # afconvert -f caff -d LEI16 -c 1 $i
    afconvert -f caff -d LEI16@11025 -c 1 $i
  done

  popd

done
