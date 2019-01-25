pushd .
cd Resources/Backgrounds

for FILE in `ls -1 *.png`
do
   NAME=`echo "$FILE" | cut -d'.' -f1`
   EXTENSION=`echo "$FILE" | cut -d'.' -f2`
   echo "Processing $FILE"
   texturetool -e PVRTC -f PVR --channel-weighting-linear --bits-per-pixel-4 -o $NAME.pvr $NAME.png
#   texturetool -e PVRTC --channel-weighting-linear --bits-per-pixel-4 -o $NAME.pvrtc $NAME.png
done 


popd
