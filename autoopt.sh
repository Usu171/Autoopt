n=2   # the nth frame of orca_pltvib


# Your ORCA path
orca_path=/home/usu171/downloads/orca_5_0_4

i=1
while true
do

    $orca_path/orca $i.inp |tee $i.out

    a=$(grep "\*\*\*imaginary mode\*\*\*" $i.out | head -1 | awk '{sub(/:/, "");print $1}')
    if  [ -n "$a" ]; then
        $orca_path/orca_pltvib $i.hess $a


        xyzfilename=$i.hess.v00$a.xyz

        number=$(awk '{print $1}' $xyzfilename | head -1)

        startline=$((3 + ( $n - 1 )*( $number + 2 )))
        endline=$((startline + number - 1))

        sed -n "${startline},${endline-1}p" $xyzfilename | awk '{print $1,$2,$3,$4}' > temp.txt


        j=$((i+1))
        cp $i.inp $j.inp

        new_startline=$(grep -nE '\*\s+xyz' $i.inp | head -1 | awk -F : '{print $1}')
        new_endline=$((new_startline + number))
        new_startline=$((new_startline + 1))

        sed -i -e "${new_startline}r temp.txt" -e "${new_startline},${new_endline}d" $j.inp

        rm temp.txt
        i=$((i+1))
    else
        break
    fi

done