export agency="MTA"
export operatorRef="$agency NYCT"
export line="$1"
export lineRef="$operatorRef_$line"

if [ -f "setenv-private.sh" ]; then
	. setenv-private.sh
fi

