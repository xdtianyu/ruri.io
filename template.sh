#!/bin/bash

set -e

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd > /dev/null
}

pushd "$(dirname "$0")"
WORK_DIR="$(pwd -P)"
popd

TITLE="$1"
IMG_DIR="$2"

CONF_FILE="$WORK_DIR/template.conf"

if [[ $# -eq 0 ]] || [[ $# -eq 1 ]]; then
    if [ -f "$CONF_FILE" ]; then
        # shellcheck source=/dev/null
        source "$CONF_FILE"
    fi
    if [ -z "$IMG_DIR" ]; then
        echo "Usage: $0 \"TITLE\" \"IMAGE DIRECTORY\""
        exit 1
    fi
fi

TMP_HTML="$WORK_DIR/.tmp.html"

if [ ! -d "$IMG_DIR" ]; then
    echo "$IMG_DIR" is not exist.
    exit 1
fi

check_sub(){
    for subdir in $(find . -maxdepth 1 -type d |grep ./ |cut -c 3-); do 
        convert_to_thumb "$subdir"
    done
}

convert_to_thumb(){
    pushd "$1"
    
    for ext in jpg JPG bmp BMP png PNG; do
        if [ ! "$(find . -maxdepth 1 -name \*.$ext | wc -l)" = 0 ]; then 
            x2thumb $ext
        fi
    done

    check_sub # check if has sub directory.
    popd
}

append_html() {
    file="$1"
    thumb="$2"

    img_dir="${PWD##*$WORK_DIR/}"

    # first image tag
    img_id=""
    if [ ! -f "$TMP_HTML" ]; then
        img_id=" id=\"first\""
    fi

    cat >> "$TMP_HTML" << EOF
      <a href="$img_dir/$file"$img_id>
        <img src="$img_dir/$thumb"/>
      </a>
EOF
}

x2thumb(){
    for file in *.$1;do
        case $file in
            *_thumb.jpg) continue;;
        esac

        thumb="${file%.*}_thumb.jpg"
        if [ ! -f "$thumb" ] ; then
            convert -thumbnail 300x240 "$file" "$thumb"
        fi
        append_html "$file" "$thumb"
    done
}

# clean last tmp

if [ -f "$TMP_HTML" ]; then
    rm "$TMP_HTML"
fi

# make thumbnail and generate image array

SAVEIFS=$IFS # setup this case the space char in file name.
IFS=$(echo -en "\n\b")

convert_to_thumb "$IMG_DIR"

IFS=$SAVEIFS

# print html content

IMG_TAG=$(cat "$TMP_HTML")

cat << EOF
<head>
    <link type="text/css" rel="stylesheet" href="static/css/lightgallery.css" /> 
    <title>$TITLE</title>
</head>  

<body>
    <script src="static/js/jquery-3.1.1.min.js"></script>
    <script src="static/js/lightgallery.js"></script>

    <script src="static/js/jquery.mousewheel.min.js"></script>

    <script src="static/js/lg-fullscreen.min.js"></script>
    <script src="static/js/lg-autoplay.min.js"></script>

    <div id="lightgallery">
$IMG_TAG
    </div>

    <script type="text/javascript">
        \$(document).ready(function() {
            var \$lg = \$("#lightgallery");
            \$lg.lightGallery({
                autoplay: true,
                progressBar: true,
                closable: false
            });
            \$("#first").click();
            //\$('.lg-close').remove();
        });
    </script>
</body>  
EOF
