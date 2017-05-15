#!/bin/bash
# docManScrape.sh
#

main() {
  lookupList=$@

  docPath="${HOME}/Projects/Docs/man/html"
  mkdir -p $docPath
  cd $docPath

  sectionList="1 2 5 6 7 8"

  for lookupCommandName in $lookupList; do
    echo -n $lookupCommandName
    for i in $sectionList; do
    manpageFoundForCommand=`man -w $i $lookupCommandName 2>/dev/null`
    if [[ -n $manpageFoundForCommand ]]; then
      echo -n " $i"
      anFileLookup=`echo $lookupCommandName | tr [:upper:] [:lower:]`
      mandoc -T html $manpageFoundForCommand > ${docPath}/${lookupCommandName}_$i.html
    fi
    done
    echo
  done

  cd ..
  # find ./html/ -name "*.html"
  pageSignatureFile="man.md5.txt"
  echo > $pageSignatureFile
  pageSignatures=""
  for anFile in `find ./html/ -name "*.html"`; do
    md5 -r $anFile >> $pageSignatureFile
    pageSignatures="$pageSignatures `md5 -q $anFile`"
  done

  sort -o $pageSignatureFile $pageSignatureFile

  if [[ `echo $pageSignatures | tr " " "\n" | wc -l` -eq `echo $pageSignatures | tr " " "\n" | sort | uniq | wc -l` ]]; then
    echo "I don't see any dupes"

    # pwd
    washCode ${docPath}/../washed/ `find ./html -iname '*.html' `

  else
    echo "Oops, is there a dupe?"
    sleep 2
    subl $pageSignatureFile
  fi
}


washCode(){
  washDir=$1 && shift
  fileList=$@

  rm -rf $washDir

  mkdir -p $washDir
  echo "washing"
  for someFile in $fileList; do

    someFileTitle=`cat $someFile | grep "<title>" | perl -pe 's/<title>(.*?)<\/title>/$1/gi'`

    titleAddString='s/(<body>)/$1<h2>'$someFileTitle'<\/h2>/gmi'

    letterPage $washDir $someFileTitle

    # echo $someFile
    cat $someFile \
    | perl -pe 's/(<\/?)h4/$1h6/gi' \
    | perl -pe 's/(<\/?)h3/$1h5/gi' \
    | perl -pe 's/(<\/?)h2/$1h4/gi' \
    | perl -pe 's/(<\/?)h1/$1h3/gi' \
    | perl -pe "$titleAddString" \
    | perl -pe 's/(<a[^>]+)class="[^>"]+"/$1/gi' \
    | perl -pe 's/(class="?)([^<>]+)\1([^<>]+\b)"?/$1$3 $2/gi' \
    | perl -pe 's/<\/body>/<hr><\/body>/gi' \
    > ${washDir}/${someFile/.*\//}
  done




}



letterPage(){
  washDir=$1 && shift
  inputString=$1 && shift
  letterUC=`echo ${inputString:0:1} | tr [:lower:] [:upper:]`
  letter=`echo ${inputString:0:1} | tr [:upper:] [:lower:]`

  # echo $letter
  echo "<!DOCTYPE html><html><head><title>$letterUC</title></head><body><h1>$letterUC</h1><hr></body></html>" > $washDir/$letter.html

}

main $@
