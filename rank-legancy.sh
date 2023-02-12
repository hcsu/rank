s() {
  RANK_FILE="$HOME/.ssh/rank"

  # check if rank file is exist
  # -e: FILE exists
  # this step is used for this case:
  #   if you trigger this function last time, but finally you didn't select an option,
  #   then there will be some rows beginning with `_ `,
  #   then next time the options in the fzf dropdown list will be deplicated
  if [ -e $RANK_FILE ]
  then
    # remove legacy items:
    # sed -i: modify the file
    # delete all rows which start from `_`
    # delete the items which inserted from last run, refreshing the options, incase the source items was changed since last run
    # for example: I inserted or deleted some hosts in the `.ssh/config`
    sed -i '' '/^_/d' $RANK_FILE
  fi

  # reload the latest hosts into rank file
  # sed clause: insert `_ ` to beginning of all items, so all items will be start with `_ `
  ag -o '(?<=^Host )(?!\*).+' ~/.ssh/config | sed 's/^/_ /' >> $RANK_FILE

  # get host need connect to (selected by you), hosts are sorted by the most counted
  # sed clause: remove the string `_ `, then the selected item will be mixed with previous itmes (all rows are not beginning with `_ `)
  SERVER=$(sed 's/^_ //' $RANK_FILE | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  # exit if host not selected
  if [ ! $SERVER ]; then
    echo "No server selected, exit!"
    return
  fi

  # save host to rank file
  echo $SERVER >> $RANK_FILE

  print -z "ssh $SERVER"
}

e() {
  RANK_FILE="$HOME/.oidc2aws/rank"

  if [ -e $RANK_FILE ]
  then
    # remove legacy items
    sed -i '' '/^_/d' $RANK_FILE
  fi

  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> $RANK_FILE

  ROLE=$(sed 's/^_ //' $RANK_FILE | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> $RANK_FILE

  print -z '$(oidc2aws -env -alias' $ROLE')'
}

o() {
  RANK_FILE="$HOME/.oidc2aws/rank"

  if [ -e $RANK_FILE ]
  then
    sed -i '' '/^_/d' $RANK_FILE
  fi

  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> $RANK_FILE

  ROLE=$(sed 's/^_ //' $RANK_FILE | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> $RANK_FILE

  if [ -z "$1" ]; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  fi

  if [ $1 = login ]; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  elif [ $1 = env ]; then
    print -z '$(oidc2aws -env -alias' $ROLE')'
    return
  else
    echo "Invalid argument, usage: 'o env' or 'o login'"
    return
  fi
}