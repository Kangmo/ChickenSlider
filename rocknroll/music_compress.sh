for dir in "media/newmusic"
do
  pushd .

  echo "processing $dir"

  cd "$dir"

  rm -rf *.m4a

  for i in *.wav; do
    # creates sound.aifc (IMA4 compression, MONO)
    afconvert -f 'm4af' -d 'aac ' -b 32768 -c 1 $i
  done

  popd

done
