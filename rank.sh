#!/bin/bash

rank() {

  local CONFIG_FILE="$1"
  local EXPRESSIONS="$2"
  local RANK_FILE="$3"

  # check if rank file is exist
  # -e: FILE exists
  # this step is used for this case:
  #   if you trigger this function last time, but finally you didn't select an option,
  #   then there will be some rows beginning with `_ `,
  #   then next time the options in the fzf dropdown list will be deplicated
  if [ -e "$RANK_FILE" ]
  then
    # remove legacy items:
    # sed -i: modify the file
    # delete all rows which start from `_`
    # delete the items which inserted from last run, refreshing the options, incase the source items was changed since last run
    # for example: I inserted or deleted some hosts in the `.ssh/config`
    sed -i '' '/^_/d' "$RANK_FILE"
  fi

  # reload the latest options into rank file
  # sed clause: insert `_ ` to beginning of all items, so all items will be start with `_ `
  ag -o "$EXPRESSIONS" "$CONFIG_FILE" | sed 's/^/_ /' >> "$RANK_FILE"

  # get option need be selected (selected by you), options are sorted by the most counted
  # sed clause: remove the string `_ `, then the selected item will be mixed with previous itmes (all rows are not beginning with `_ `)
  SORT_DISPLAY_OPTION=$(sed 's/^_ //' "$RANK_FILE" | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  # exit if SORT_DISPLAY_OPTION is null
  # this will avoid insert a empty line into rank file
  if [ -z "$SORT_DISPLAY_OPTION" ]
  then
    return
  else
    # save option to rank file
    echo "$SORT_DISPLAY_OPTION" >> "$RANK_FILE"
    # print -z "$EXECUTE $SORT_DISPLAY_OPTION"
    printf "%s" "$SORT_DISPLAY_OPTION"
  fi
}