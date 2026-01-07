#!/bin/sh
# readip.sh
# The script generate (and play) ip.wav from numbers.wav for the current IP or the number passed as parameter
# Usage readip.sh -> play the current IP
#		readip.sh 12.34 read "one two (500mS) three four" 

ipadd="$1"
NUMBERS_WAV="/mnt/numbers.wav"
OUTPUT_WAV="/tmp/ip.wav"
SILENCE_FILE=/tmp/silence.wav
SILENCE_POINT_FILE=/tmp/silence_point.wav
HEADER_SIZE=44
NUM_LEN=4800        # 600ms at 8kHz A-LAW
PAUSE_LEN=400       # 50ms silence between numbers
POINT_LEN=4000      # 500ms silence for the dot
SILENCE_BYTE="\xD5"
    
# Numbers offset byte table (start_time * 8000 + HEADER_SIZE)
get_offset() {
    case "$1" in
        0) echo 2084 ;;
        1) echo 13244 ;;
        2) echo 23000 ;;
        3) echo 32044 ;;
        4) echo 42708 ;;
        5) echo 52364 ;;
        6) echo 62244 ;;
        7) echo 72044 ;;
        8) echo 83244 ;;
        9) echo 93204 ;;
        *) echo 105000 ;;
    esac
}

# wav file generation function
generate_ip_wav() {
    IP="$1"
    rm -f "$OUTPUT_WAV"

    # 1) header WAV provvisorio
    printf 'RIFF\x00\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x06\x00\x01\x00\x40\x1F\x00\x00\x40\x1F\x00\x00\x01\x00\x08\x00fact\x04\x00\x00\x00\x00\x00\x00\x00data\x00\x00\x00\x00' > "$OUTPUT_WAV"

    TOTAL_DATA_LEN=0

    # Silence temp files
    head -c $PAUSE_LEN /dev/zero | tr '\0' "$SILENCE_BYTE" > "$SILENCE_FILE"
    head -c $POINT_LEN /dev/zero | tr '\0' "$SILENCE_BYTE" > "$SILENCE_POINT_FILE"

    i=1
    LEN=$(echo "$IP" | awk '{print length($0)}')
    while [ $i -le $LEN ]; do
        C=$(echo "$IP" | cut -c$i)

        case "$C" in
            [0-9])
                OFFSET=$(get_offset "$C")
                dd if="$NUMBERS_WAV" bs=1 skip=$OFFSET count=$NUM_LEN 2>/dev/null >> "$OUTPUT_WAV"
                TOTAL_DATA_LEN=$(( TOTAL_DATA_LEN + NUM_LEN ))

                # Pause between numbers
                cat "$SILENCE_FILE" >> "$OUTPUT_WAV"
                TOTAL_DATA_LEN=$(( TOTAL_DATA_LEN + PAUSE_LEN ))
                ;;
            ".")
                # Punto = 500ms silenzio
                cat "$SILENCE_POINT_FILE" >> "$OUTPUT_WAV"
                TOTAL_DATA_LEN=$(( TOTAL_DATA_LEN + POINT_LEN ))
                ;;
        esac

        i=$(expr $i + 1)
    done

    # 2) update WAV header with correct lenghts
    RIFF_SIZE=$(( TOTAL_DATA_LEN + 36 ))
    DATA_SIZE=$TOTAL_DATA_LEN

    printf $(printf '\\x%02x\\x%02x\\x%02x\\x%02x' $((RIFF_SIZE & 0xFF)) $(((RIFF_SIZE>>8)&0xFF)) $(((RIFF_SIZE>>16)&0xFF)) $(((RIFF_SIZE>>24)&0xFF))) | dd of="$OUTPUT_WAV" bs=1 seek=4 count=4 conv=notrunc 2>/dev/null
    printf $(printf '\\x%02x\\x%02x\\x%02x\\x%02x' $((DATA_SIZE & 0xFF)) $(((DATA_SIZE>>8)&0xFF)) $(((DATA_SIZE>>16)&0xFF)) $(((DATA_SIZE>>24)&0xFF))) | dd of="$OUTPUT_WAV" bs=1 seek=40 count=4 conv=notrunc 2>/dev/null

    # Remove temp files
    rm -f "$SILENCE_FILE" "$SILENCE_POINT_FILE"
}

#######################################################################################
# If no number as parameter, retrive the current IP, generate the wav file and play it.
#
if [ -z $ipadd ]; then
	ipadd=$(ifconfig wlan0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	echo $ipadd
	attesa=5
	generate_ip_wav $ipadd
	
else
	attesa=0
fi
# generate wav file and play it	
generate_ip_wav $ipadd
(sleep $attesa && httpclt get "http://127.0.0.1:8001/playaudio?file=/tmp/ip.wav") &

#<EOF>