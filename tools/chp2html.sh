#!/bin/bash

DIR="/webpage/tn"
TEMPLATE=${DIR}/tools/chapter.tmpl.html
title="${1}"
_title=${title}

[ -z "${title}" ] && exit 0
[ -d ${DIR}/novels/"${title}" ] ||\
  { >&2 echo ch2html: ${DIR}/novels/${title} does not exist!; exit 1; }
tmpdir=$(mktemp -d /tmp/ch2html.XXXXX)
mkdir -p ${tmpdir}/build
mkdir -p ${DIR}/site/n/${_title}

cd ${DIR}/novels/"${title}"
cnauthor=`cat data/details | tail -1 | sed "s/.*%%//g"`
author=`cat data/details | tail -1 | sed "s/%%.*//g"`
cntitle=`cat data/details | head -1 | sed "s/.*%%//g"`
title=`cat data/details | head -1 | sed "s/%%.*//g"`
###echo $cntitle
##pwd
#  chapters="<details> \
#            <summary title=\"Quick select\">Chapters<\/summary> \
#    	      <br><a href=\"#top\">[1]<\/a><br> \
#              <a href=\"#top\">[2]<\/a><br> \
#              <a href=\"#top\">[3]<\/a> \
#    	    <\/details>"

list=${tmpdir}/list
for p in $(ls *.chp | sort -h | sed 's/\.chp//g'); do
	echo -n "<a href=\\\"${p%|*}.html\\\" title=\\\"$(echo ${p#*|} | sed 's/_/ /g')\\\">${p%|*}<\/a><br>" >> ${list}
	touch ${tmpdir}/build/${p%\|*}.html

done

###echo 0
#cat ${list}
###echo 0
edit() {
  refs="$(cat ${1} | grep -oe "\*{[0-9]\+}")"
  for ref in ${refs}; do 
    num=$(echo "${ref}" | grep -oe "[0-9]*")
    _ref="<sup><a id=\"ref-${num}\" href=\"#note-${num}\">[${num}]<\\/a><\\/sup><\\/p>"

    sed -i ${1} \
  	-e "s/${ref}/${_ref}/g"
  done

  erefs="$(cat ${1} | grep -oe "\*{_[0-9]\+}")"
  for eref in ${erefs}; do
    num=$(echo "${eref}" | grep -oe "[0-9]*")
    _eref="<a id=\"note-${num}\" href=\"#ref-${num}\">[${num}] ↑ <\\/a>"

    sed -i ${1} \
  	-e "s/${eref}/${_eref}/g" \

  done
  prevf=$(( ${2} - 1 )).html
  nextf=$(( ${2} + 1 )).html
  [ ! -f ${tmpdir}/build/${prevf} ] && prevf="${_title}.html"
  [ ! -f ${tmpdir}/build/${nextf} ] && nextf="${_title}.html"
  echo "|||||||||||||||||||||||||||||||||||+"
  echo "${tmpdir}/build/{${prevf},${nextf}}"
  ls "${tmpdir}/build"
  echo "|||||||||||||||||||||||||||||||||||-"
## ACTUAL:
#  [ ! -f ${prevf} ] && prevf="index.html"
#  [ ! -f ${nextf} ] && nextf="index.html"
##  unset prev next
  prev="<a href=\"${prevf}\" id=\"prev\">← Prev <\/a>"
  next="<a href=\"${nextf}\" id=\"next\"> Next →<\/a>"
  backtotop="<div class=\"backtotop\">\
<a href=\"#top\">[↥]<\/a>\
<\/div>"
  chapters="<details class=\"chapters\"><summary title=\"Hover for chapter titles\">☷<\/summary><br> "$(cat ${list})"<\/details>"
###  echo "${chapters}"
  index="<a href=\"${_title}.html\"> Index <\/a>"
  menu="<hr>\n<div class=\"menu\"> ${prev} ${index} ${next} <\/div>"
###  echo ------------------- `date` `date +%s%3N`
  sed -i ${1} \
      -e "s/^%%[0-9].* UTC/<p class=\"center\">&<\/p>/g" \
      -e "s/\*{<>}/${menu}/g" \
      -e "s/\*{\^}/${backtotop}/g" \
      -e "s/\*{@}/<div class=\"chapters\">${chapters}<\/div>/g" \
      -e "s/\*{--}/<hr \/>/g" \
      -e "s/\*{-;}/<hr class=\"content\" \/>/g" \
      -e "s/\*{\!}/<h1>$(echo ${f%.*} | sed -e 's/_/ /g' -e 's/|/ · /g')<\\/h1>/g" \
      -e "1s/^/${title}<sub> ${cntitle}<\/sub><br>By ${author}<sub> ${cnauthor}<\/sub>/g" \
      -e "s/^/<p>/g" \
      -e "s/$/<\/p>/g" \
      -e "s/\t/\&emsp;/g" \
      -e "s/<p><\/p>/<br>/g" \
      -e "s/<p></</g" \
      -e "s/><\/p>/>/g" \
      -e "s/%%//g"
###  echo ----------------------------------
###  echo ${menu}
###  echo ${backtotop}
}

for f in $(ls -1 *.chp); do
  chapternum=$(echo "$f" | grep -oe "^[0-9]*")
  chaptername=$(echo ${f#*|} | sed 's/.chp$//g')
  echo Converting $f to ${chapternum}.html
  out=${chapternum}.html
  # [ -f ${out} ] && continue
  tmpfile=${tmpdir}/${out}
		echo "Formatting..."
	echo -e "-> cp \"${f}\" ${tmpfile}"


  cp "${f}" ${tmpfile}

	echo -e "---> edit ${tmpfile} ${chapternum}"
  edit ${tmpfile} ${chapternum}
	echo "ok"
###  echo $out 0

	echo "getting ${TEMPLATE} lines"
  contentline=$(cat ${TEMPLATE} | grep -ne "^\s%CONTENT%$" | grep -oe "^[0-9]*")
  templateline=$(wc -l ${TEMPLATE} | grep -oe "^[0-9]*")
  echo 000 $contentline 000 $templateline ==============
  headl=$(( ${contentline} - 1 ))
  echo $headl ---------------
  taill=$(( ${templateline} - ${contentline} ))
  echo $taill +++++++++++++++

	echo -e "
-> head -${headl} ${TEMPLATE} > ${tmpdir}/build/${out} &&
--	 ...
->	 tail -${taill} ${TEMPLATE} >> ${tmpdir}/build/${out}"

  head -${headl} ${TEMPLATE} > ${tmpdir}/build/${out} && \
	  cat ${tmpfile} >> ${tmpdir}/build/${out} && \
	  tail -${taill} ${TEMPLATE} >> ${tmpdir}/build/${out}
	echo -e "-- tidy -ibq --tidy-mark no -w 0 ${tmpdir}/build/${out} | sed... > ${tmpfile}"
  tidy -ibq --tidy-mark no -w 0 ${tmpdir}/build/${out} | sed "s/<title>/<title>${title} - Chapter ${chapternum}/g" > ${tmpfile}

	echo -e "-> mv ${tmpfile} ${DIR}/novels/${_title}/html/${out}\n"
  mv ${tmpfile} ${DIR}/novels/${_title}/html
	echo -e "Create symbolic link: "
  ln -svf ${DIR}/novels/${_title}/html/${out} ${DIR}/site/n/${_title}/${out}
	echo -e "done\n"
 # rm ${tmpfile}
  #cat ${tmpdir}/$out

##ACTUAL
#  head -9 ${TEMPLATE} > ${out} && \
#	  cat ${tmpfile} >> ${out} && \
#	  tail -2 ${TEMPLATE} >> ${out}
#  tidy -ibq --tidy-mark no -w 0 ${out} | sed "s/<title>/<title>${title} - Chapter ${chapternum}/g" > ${tmpfile}
#  mv ${tmpfile} ${out}
  
done

indexf=${DIR}/site/n/${_title}/${_title}.html
[ ! -e "${indexf}" ] && ln -s ${DIR}/novels/${_title}/html/"${_title}.html" "${indexf}"
	echo "cd --"
cd --
	echo "rm -r ${tmpdir}"
rm -r ${tmpdir}
	echo -e "Finished\n"

