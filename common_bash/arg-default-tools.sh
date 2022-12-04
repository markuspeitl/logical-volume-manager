#!/bin/sh

setDefault(){
    ARG="$1"
    DEFAULT="$2"
    
    if [ -n "$ARG" ]; then
        echo "$ARG"
    else
        echo "$DEFAULT"
    fi
}

setArgEnvDefault(){
    ARG="$1"
    ENV="$2"
    DEFAULT="$3"
    
    if [ -n "$ARG" ]; then
        echo "$ARG"
    elif [ -n "$ENV" ]; then
        echo "$ENV"
    else 
        echo "$DEFAULT"
    fi
}