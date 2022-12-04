#!/bin/sh

expandScriptDependencies(){
    SCRIPT_RELATIVE_PATH="$1"
    #SCRIPT_CONTENTS="$1"

    SCRIPT_CONTENTS=$(cat "$(dirname "$0")/$SCRIPT_RELATIVE_PATH")
   
    ABS_SCRIPT_FILE_PATH="$(dirname "$0")/$SCRIPT_RELATIVE_PATH"
    ABS_SCRIPT_DIR_PATH="$(dirname "$ABS_SCRIPT_FILE_PATH")"
    #echo "$SCRIPT_CONTENTS"
    #echo "$SCRIPT_DIR_PATH"


    TMP_FILE=/tmp/remote-exec-temp
    echo "" > $TMP_FILE

    while IFS= read -r SOURCE_LINE; do
        INCLUDE_LINE=$(echo "$SOURCE_LINE" | grep -E "^[ ]*[\.|bash|sh|source]+[ ]+.+[a-zA-Z0-9_-]+\.sh")

        if [ -n "$INCLUDE_LINE" ]; then
            #echo "ISINCLUDE $INCLUDE_LINE"

            INCLUDE_LINE=$(echo "$INCLUDE_LINE" | sed -e "s:^[ ]*[\.|bash|sh|source][ ]*::g")
            INCLUDE_PATH=$(echo "$INCLUDE_LINE" | sed "s:\$(dirname \"\$0\"):$ABS_SCRIPT_DIR_PATH:g" | sed 's:"::g')

            INCLUDE_SCRIPT_CONTENTS=$(cat "$INCLUDE_PATH")

            printf "%s\n" "$INCLUDE_SCRIPT_CONTENTS" >> $TMP_FILE
        else
            #echo "IS SOURCE LINE: $SOURCE_LINE"
            printf "%s\n" "$SOURCE_LINE" >> $TMP_FILE
        fi
    done <<< $SCRIPT_CONTENTS

    cat "$TMP_FILE"
}

remoteExecScript(){
    REMOTE_SSH_TARGET="$1"
    FULL_SCRIPT="$2"

    printf "Sending:\n%s\n" "$FULL_SCRIPT"

    ssh -t "$REMOTE_SSH_TARGET" "$FULL_SCRIPT"
}

combineScript(){
    SCRIPT_RELATIVE_PATH="$1"
    ENV_ARGUMENTS="$2"
    SCRIPT_CONTENTS=$(cat "$(dirname "$0")/$SCRIPT_RELATIVE_PATH")
    SCRIPT_CONTENTS=$(expandScriptDependencies "$SCRIPT_RELATIVE_PATH")

    SHE_BANG=$(echo "$SCRIPT_CONTENTS" | awk '{if(NR==1 && substr($1,1,1) ~ "#")print $0}')
    BODY_CONTENTS=$(echo "$SCRIPT_CONTENTS" | awk '{if(NR>1)print}')

    FULL_SCRIPT=$(printf "%s\n%s\n%s\n" "$SHE_BANG" "$ENV_ARGUMENTS" "$BODY_CONTENTS")

    echo "$FULL_SCRIPT"
}

combineSendScript(){
    REMOTE_SSH_TARGET="$1"
    SCRIPT_RELATIVE_PATH="$2"
    ENV_ARGUMENTS="$3"

    FULL_SCRIPT=$(combineScript "$SCRIPT_RELATIVE_PATH" "$ENV_ARGUMENTS")
    remoteExecScript "$REMOTE_SSH_TARGET" "$FULL_SCRIPT"
}

combinePrintScript(){
    REMOTE_SSH_TARGET="$1"
    SCRIPT_RELATIVE_PATH="$2"
    ENV_ARGUMENTS="$3"

    FULL_SCRIPT=$(combineScript "$SCRIPT_RELATIVE_PATH" "$ENV_ARGUMENTS")
    printf "Sending:\n%s\n" "$FULL_SCRIPT"
}

passEnvironmentVars(){
    #VARS_TO_PASS="$@"
    echo "passEnvironmentVars"

    for VAR_NAME in "$@"
    do
        LINE="$VAR_NAME=$(setArgEnvDefault "${!VAR_NAME}")"
    done
}