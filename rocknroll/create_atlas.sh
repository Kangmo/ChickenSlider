d=sprites
echo "Processing : $d"
pushd .

cd Resources/$d

TexturePacker --data ../${d}.plist --format cocos2d --sheet ../${d}.pvr *.png

popd

d=menu_sprites
echo "Processing : $d"
pushd .

cd Resources/$d

TexturePacker --data ../${d}.plist --format cocos2d --sheet ../${d}.pvr *.png

popd


d=title_anim_sprites
echo "Processing : $d"
pushd .

cd Resources/$d

TexturePacker --data ../${d}.plist --format cocos2d --sheet ../${d}.pvr *.png

popd


