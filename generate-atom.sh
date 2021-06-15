#!/bin/sh

function htmlEscape () {
    local s
    s=${1//&/&amp;}
    s=${s//</&lt;}
    s=${s//>/&gt;}
    s=${s//'"'/&quot;}
    printf -- %s "$s"
}

BLOG_POST_TEMPLATE="_layouts/post.html"

POST_DIR="_posts/"
POST_LIST=$(ls -w 1 $POST_DIR)

#POST_FILE_NAMES=$(printf "$POST_LIST" | awk '{print $7}')
readarray POST_FILE_NAMES < <(printf "$POST_LIST" | awk '{$1=$1};1')

COUNT=$(echo "$POST_LIST" | wc -l)
printf "Posts Count: $COUNT\n"

for index in $(seq 0 $(($COUNT - 1)))
do
  filename=$(printf "${POST_FILE_NAMES[$index]}" | tr -d '\n')
  date_created=$(stat -c "%W" "$POST_DIR$filename")
  date_created=$(date -u -d @"$date_created" +"%Y-%m-%dT%H:%M:%S%:z")
  date_modified=$(stat -c "%Y" "$POST_DIR$filename")
  date_modified=$(date -u -d @"$date_modified" +"%Y-%m-%dT%H:%M:%S%:z")

  printf "$index $filename\n"
  printf "$date_created $date_modified\n"

  html_fragment=$(\
    pandoc -M date="$date_created" -t html "$POST_DIR$filename" \
    | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' \
  )

  # Converting frontmatter to bash variables:
  # https://www.reddit.com/r/pandoc/comments/f6oxm5/convert_yaml_frontmatter_to_bash_variables/
  # Basically create a bash template then source it in the script

  id="TODO"
  title="TODO"
  link="TODO"
  summary="TODO"
  categories="" # TODO: Generate categories

  entry=`cat <<EOF
<entry>
  <id>$id</id>
  <title>$title</title>
  <link href="$link" />
  <published>$date_created</published>
  <updated>$date_modified</updated>
  $categories
  <summary>$summary</summary>
  <content xml:lang="en-GB" type="html">
  $html_fragment
  </content>
</entry>
EOF
`

  echo "$entry"
  #echo "$html_fragment" > "test.html"
  #read -n 1 -s -r -p "Press any key to continue\n"
done

