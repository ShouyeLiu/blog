#!/bin/bash

cat > ~/blog/html/rss.xml <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<?xml-stylesheet type="text/css" href="../aux/rss.css"?>
<rss version="2.0">

<channel>
<title>Mathematical Field Notes</title>
  <link>http://www.homepages.ucl.ac.uk/~ucahjde/blog/</link>
  <description>Blog of the UCL-based mathematician Jonny Evans</description>
EOF

headingnum=0
linked=0
rootaddress='https://www.homepages.ucl.ac.uk/~ucahjde/blog/'

while read -r line
do
    if echo "$line" | grep "^\*\s" &> /dev/null
    then
	if [ $linked == 0 ];
	then
	    echo "<link>$rootaddress</link>" >>  ~/blog/html/rss.xml
	fi
	linked=0
	if [ $headingnum != 0 ];
	then
	    echo "</item>" >>  ~/blog/html/rss.xml
	fi
	let headingnum=$headingnum+1
	title=$(echo "$line" |
		    perl -pe 's|^\*\s(.*?)\s*:[a-zA-Z:]*:|\1|' |
		    gawk '{print "<item><title>",$0,"</title>"}'
	     )
	tags=$(echo "$line" |
		   perl -pe 's|^.*?(:[a-zA-Z:]*:)|\1|' |
		   gawk -F':' '{for (k=2;k<=NF-1;k++) print "<category>",$k,"</category>"}'
	    )
	echo "$title" >>  ~/blog/html/rss.xml
	echo "$tags" >>  ~/blog/html/rss.xml
    fi
    if echo "$line" | grep "\[[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\s[A-Za-z]\{3\}\]" &> /dev/null
    then
	pubdate=$(echo "$line" |
		      sed 's|\[\(.*\)\]|\1|' |
		      gawk '{print "<pubDate>",$0,"</pubDate>"}'
	       )
	echo "$pubdate" >>  ~/blog/html/rss.xml
    fi
    if echo "$line" | grep "\[Read on.*\]\]" &> /dev/null
    then
	linked=1
	link=$(echo "$line" |
		   sed 's|^\[\[\./\(.*\)\.org\]\[Read on.*\]\].*$|\1|' |
		   gawk -v x=$rootaddress '{print "<link>"x$0".html</link>"}'
	    )
	echo "$link" >>  ~/blog/html/rss.xml
    fi
done < ~/blog/org/index.org

if [ $linked == 0 ];
then
    echo "<link>$rootaddress</link>" >>  ~/blog/html/rss.xml
fi


cat >> ~/blog/html/rss.xml <<EOF
</item>
</channel>
</rss>
EOF
