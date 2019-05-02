#!/bin/sh
# Light novel downloader
# by FalkorX


# Load external config
source 'user.cfg'

# Extract domain
domain=${url_format##*//}
domain=${domain%%/*}

# Load domain specific config
source 'domain.cfg'

# Automatically escape slashes
start_separator=`echo "$start_separator" | sed 's:/:\\\/:g'`
end_separator=`echo "$end_separator" | sed 's:/:\\\/:g'`


# File names
temp_subfolder="$novel_name"
output_fname="$novel_name.txt"


# Make temp dir
mkdir -p "$temp_subfolder"

# Clear output file
echo '' >"$output_fname"


# Start processing
echo 'Config successfully loaded! Start download...'

# Process chapters
for i in `seq $i_begin $i_end`; do
    for i_format in "$i" "0$i" "00$i" "000$1"; do
        url=`echo "$url_format" | sed "s/##/$i_format/"`
        fname="$temp_subfolder/Chapter $i_format.txt"
        
        response=`wget -q --server-response --spider "$url" 2>&1 | sed -n '/HTTP\/1.1 200 OK/ p'`
        if [ -n "$response" ]; then
            echo "Downloading $url to $fname..."
            wget -q --output-document="$fname" --no-clobber "$url"
            
            echo "Extracting text data..."
            sed -n -i '/'"$start_separator"'/,/'"$end_separator"'/ p' "$fname"
            
            sed \
            -e 's:\n::g' \
            -e 's:<br>:\n:g' \
            -e 's:</p>:\n:g' \
            -e 's:<hr>:--------------------------------------------------------\n:g' \
            -e 's:&nbsp;::g' \
            -e 's:<[^>]*>::g' \
            <"$fname" >>"$output_fname"
            
            break
        fi
    done
done
cd $temp_subfolder
for x in ./*.txt; do
  mkdir "${x%.*}" && mv "$x" "${x%.*}"
done
echo "Done!"
