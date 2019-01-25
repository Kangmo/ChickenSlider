rm -rf ~/temp/game01
mkdir ~/temp/game01
for d in "Clips Resources fonts levels menus"
do
    echo "$d"
    for f in `find $d -name "*"`
    do 
        if [ -f "$f" ]; then
            echo "$f"
            cp "$f" ~/temp/game01
        fi
    done
done
