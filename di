#!/usr/bin/env bash
# Dir info
SHOW_USAGE='echo -e "Directory Information tool\nUsage:\n\tdi\n\tdi <DIR>\n\tdi <b|B|m|M|k|K|g|G>\n\tdi <DIR> <b|B|m|M|k|K|g|G>"'

if [[ $# -eq 0 ]]; then
    WKDIR=.
    SIZE_FILTER=""
elif [[ $# -eq 1 ]]; then
    if [[ -d "$1" && -x "$1" ]]; then
	WKDIR="$1"
	SIZE_FILTER=""
    elif [[ "$1" =~ ^[bBkKmMgG]$ ]]; then
	WKDIR=.
	SIZE_FILTER="$1"
    else
	eval $SHOW_USAGE
	exit 1
    fi
elif [[ $# -eq 2 ]]; then
    if [[ -d "$1" && -x "$1" && "$2" =~ ^[bBkKmMgG]$ ]]; then
	WKDIR="$1"
	SIZE_FILTER="$2"
    else
	eval $SHOW_USAGE
	exit 2
    fi
else
    eval $SHOW_USAGE
    exit 3
fi

FORMAT_STR="%-5s%-5s%6s%5s\t%s\n"    
PRINT_HEAD='printf $FORMAT_STR "IDX" "TYPE" "SIZE" "NUM" "ITEM"'
HEAD_PRINTED=NO

IFS_OLD="$IFS"
IFS="$(printf '\n\t')"

FILES=$(find $WKDIR -maxdepth 1 -print 2>/dev/null)

let IDX=1
let SIZE_TOTAL=0
for FILE in $FILES; do
    if [[ -d "$FILE" ]] && [[ $FILE != "$WKDIR" ]]; then
	SIZE=$(du -hd0 "$FILE" 2>/dev/null |awk '{print $1}')
	if [[ $SIZE =~ ^[0-9]*$ ]]; then SIZE=$SIZE"B"; fi
	
	if [[ ( -z $SIZE_FILTER ) ||
		    ( $SIZE_FILTER =~ ^[b|B]$ && $SIZE =~ .*[b|B]$ ) ||
		    ( $SIZE_FILTER =~ ^[k|K]$ && $SIZE =~ .*[k|K]$ ) ||
		    ( $SIZE_FILTER =~ ^[m|M]$ && $SIZE =~ .*[m|M]$ ) ||
		    ( $SIZE_FILTER =~ ^[g|G]$ && $SIZE =~ .*[g|G]$ ) ]] ; then
	    ITEM_NUM=$(ls -A1 "$FILE" 2>/dev/null |wc -l |awk '{print $1}')
	    [[ $HEAD_PRINTED = NO ]] && { eval "$PRINT_HEAD"; HEAD_PRINTED=YES; }
	    printf "$FORMAT_STR" "$IDX" "Dir" "$SIZE" "$ITEM_NUM" "$(basename $FILE)"
	    if [[ -n $SIZE_FILTER ]]; then
			SIZE_TOTAL=$(awk -v t=$SIZE_TOTAL '{print t+substr($0,1,length($0)-1)}' <<<"$SIZE")
	    fi
	    let IDX=$IDX+1
	fi
    elif [[ -f "$FILE" ]]; then
        # Get file size
        # `ls version' is more precise than `du version', just as the result of `stat'.
        # `stat' has no `human-readable' output predefined.
		SIZE=$(ls -lh "$FILE" 2>/dev/null |awk '{print $5}')
        #SIZE=$(du --si "$FILE" 2>/dev/null |cut -f 1)
		if [[ "$SIZE" =~ ^[0-9]*$ ]]; then SIZE=$SIZE"B"; fi

		if [[ ( -z $SIZE_FILTER ) ||
		    ( $SIZE_FILTER =~ ^[b|B]$ && $SIZE =~ .*[b|B]$ ) ||
		    ( $SIZE_FILTER =~ ^[k|K]$ && $SIZE =~ .*[k|K]$ ) ||
		    ( $SIZE_FILTER =~ ^[m|M]$ && $SIZE =~ .*[m|M]$ ) ||
		    ( $SIZE_FILTER =~ ^[g|G]$ && $SIZE =~ .*[g|G]$ ) ]] ; then
	    [[ $HEAD_PRINTED = NO ]] && { eval "$PRINT_HEAD"; HEAD_PRINTED=YES; }
	    printf "$FORMAT_STR" "$IDX" "File" "$SIZE" "1" "$(basename $FILE)"
	    if [[ -n $SIZE_FILTER ]]; then
	    	#SIZE_LEN=$(expr length $SIZE)
	    	#SIZE_TOTAL=$(bc <<< "scale=6;$SIZE_TOTAL+$(expr substr $SIZE 1 $(($SIZE_LEN-1)))")
			SIZE_TOTAL=$(awk -v t=$SIZE_TOTAL '{print t+substr($0, 1, length($0)-1)}' <<<"$SIZE")
	    fi
	    let IDX=$IDX+1
	fi
    fi
done

# Show size total if there is a filter
if [[ -n $SIZE_FILTER ]]; then
    printf "Total: %.1f%s, %s item(s).\n" $SIZE_TOTAL $(echo $SIZE_FILTER |tr '[bkmg]' '[BKMG]') $(($IDX-1))
fi

# Show working dir's info at last
SIZE=$(du -hd0 "$WKDIR" 2>/dev/null |awk '{print $1}')
if [[ "$SIZE" =~ ^[0-9]*$ ]]; then SIZE=$SIZE"B"; fi

# if [[ ( -z $SIZE_FILTER ) ||
# 	    ( $SIZE_FILTER =~ ^[b|B]$ && $SIZE =~ .*[b|B]$ ) ||
# 	    ( $SIZE_FILTER =~ ^[k|K]$ && $SIZE =~ .*[k|K]$ ) ||
# 	    ( $SIZE_FILTER =~ ^[m|M]$ && $SIZE =~ .*[m|M]$ ) ||
# 	    ( $SIZE_FILTER =~ ^[g|G]$ && $SIZE =~ .*[g|G]$ ) ]] ; then
#     ITEM_NUM=$(ls -A1 "$WKDIR" 2>/dev/null |wc -l |cut -f 1)
#     [[ $HEAD_PRINTED = NO ]] && { eval "$PRINT_HEAD"; HEAD_PRINTED=YES; }
#     printf "$FORMAT_STR" "$IDX" "Dir" "$SIZE" "$ITEM_NUM" "CURRENT_DIR: ${WKDIR%/}"
# fi
ITEM_NUM=$(ls -A1 "$WKDIR" 2>/dev/null |wc -l |awk '{print $1}')
printf "Folder: %s, %s item(s).\n" $SIZE $ITEM_NUM

IFS="$IFS_OLD"
