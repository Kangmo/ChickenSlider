FILE_NAME=$1
sed 's/WaterDrop.png/Feather.png/g' $FILE_NAME > ${FILE_NAME}.tmp
mv ${FILE_NAME}.tmp ${FILE_NAME} 
