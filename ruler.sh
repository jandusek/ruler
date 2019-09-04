#!/bin/bash
# based on this thread: https://stackoverflow.com/questions/44090880/create-png-rectangle-with-rulers-along-edges

WIDTH=$1
HEIGHT=$2
TL=10
STROKE="#008CFF"
POINTSIZE=20
FONT=~/fonts/lekton/Lekton-Regular.ttf

display_usage() { 
    echo -e "Usage: $0 <width> <height>\n"
}

if [ $# -ne 2 ]; then
   display_usage
   exit 1
fi

TMP_IMG=$(mktemp)
TMP_FILE=$(mktemp)

# Draw ticks using a loop across width of ruler
for ((i=0;i<$WIDTH;i+=10)); do

   # Decide tick length, doubling length if multiple of 100
   r=$TL
   [[ $((i%50)) -eq 0 ]] && ((r=3*TL/2))
   [[ $((i%100)) -eq 0 ]] && ((r=2*TL))

   # Draw ticks along top edge of ruler
   echo line $i,0 $i,$r

   # Draw ticks along bottom edge of ruler
   echo line $i,$HEIGHT $i,$((HEIGHT-r))

   # Add numbering labels
   if [ $((i%100)) -eq 0 ] && [ $i -gt 0 ] && [ $i -lt $((WIDTH-80)) ]; then
      echo text $i,$((40+POINTSIZE)) \"$i\"
      echo text $i,$((HEIGHT-80+POINTSIZE*3/2)) \"$i\"
   fi

done > $TMP_FILE
convert -density 72 -size ${WIDTH}x${HEIGHT} xc:white -fill $STROKE -stroke $STROKE -font $FONT -pointsize $POINTSIZE -strokewidth 1 -draw @"$TMP_FILE" "png:$TMP_IMG"

# Draw ticks down sides of ruler
for ((i=0;i<$HEIGHT;i+=10)); do

   # Decide tick length, doubling length if multiple of 100
   r=$TL
   [[ $((i%50)) -eq 0 ]] && ((r=3*TL/2))
   [[ $((i%100)) -eq 0 ]] && ((r=2*TL))

   # Draw ticks along left edge of ruler
   echo line 0,$i $r,$i
   # Draw ticks along right edge of ruler
   echo line $((WIDTH-r)),$i $WIDTH,$i

   # Add numbering labels
   if [ $((i%100)) -eq 0 ] && [ $i -gt 0 ] && [ $i -lt $((HEIGHT-75)) ]; then
      echo text 40,$i \"$i\"
      echo text $((WIDTH-80)),$i \"$i\"
   fi

done > $TMP_FILE
convert "png:$TMP_IMG" -density 72 -stroke $STROKE -font $FONT -fill $STROKE -pointsize $POINTSIZE -strokewidth 1 -draw @"$TMP_FILE" "png:$TMP_IMG"

convert "png:$TMP_IMG" -stroke $STROKE -strokewidth 1 -fill none \
  -draw "rectangle 0,0 $((WIDTH-1)),$((HEIGHT-1))" $TMP_IMG

convert -size ${WIDTH}x${HEIGHT} -background '#00000000' -fill $STROKE -font $FONT -gravity center -pointsize $((POINTSIZE*5)) \
  label:${WIDTH}x$HEIGHT miff:- |\
  composite -gravity center -geometry +0+5 \
              - "png:$TMP_IMG" ruler_${WIDTH}x${HEIGHT}.png

rm $TMP_IMG
rm $TMP_FILE


