
appName="manPages"
outputFile=${appName}.epub
uname=${shell uname -sr}
unameAll=${shell uname -a}

date=${shell date "+%Y-%m-%d"}

shortList="awk bash bdig brew builtin cal calendar cat chroot chown chflags chpass chmod cmatrix cp cron crontab curl cut cvs date dig echo env file find fish git grep hostname ifconfig inet join kill killall less locate ls lsof make man md5 mkdir mv nano nslookup open pandoc perl ping pmset ps pwd rm ruby sed sort split ssh sshfs stty sudo tail terminfo top touch tput tr traceroute uniq uptime wc wget which who whois zip"


force: ;

.PHONY: clean clean-edit clean-mirror codeWash download publish force metadata frontPage


metadata: force;
	echo "<dc:title>man Pages from ${shell uname}</dc:title>\n<dc:alternative></dc:alternative>\n<dc:creator>${shell hostname} on ${date}</dc:creator>\n<dc:author>Various Authors</dc:author><dc:rights>Various Authors</dc:rights>" > metadata.xml

frontPage: force;
	echo "<!DOCTYPE html>\n<html>\n<head>\n<title>man Pages from ${shell hostname}, ${date}</title>\n</head>\n<body>\n<h1>man Pages</h1>\n<p>Various Authors</p>\n<h2>${shell hostname}</h2><pre>${unameAll}</pre>\n<hr>\n</body>\n</html>" > washed/zzzzzzzzzzzzzzzzzzzzzzzz.html
	cp washed/zzzzzzzzzzzzzzzzzzzzzzzz.html washed/-1.html

addition: force;
	pandoc addition/*.md \
	-o "washed/1 - additional.html"

clean: clean-edit clean-mirror

clean-edit:
	-rm washed/*.html


clean-mirror:
	-rm html/*.html

scrape:
	./docManScrape.sh ${shortList}

sort:
	@echo ${sort Q W D f s d f s D F a s d o j m a }


publish: ${outputFile}

open:
	open ${outputFile}

pub: publish;

${outputFile}: frontPage metadata addition;
	# ${MAKE}
	pandoc \
		./washed/*.html \
		--epub-stylesheet=book.css \
		--epub-metadata=metadata.xml \
		--epub-chapter-level=1 \
		-o ${outputFile}


