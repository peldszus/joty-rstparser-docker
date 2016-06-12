#!/bin/sh
echo "### Processing $1 ..."
if [ ! -f "$1.rst" ]; then
	rm -f tmp.* tmp_*
	echo "  .segmenting"
	python Discourse_Segmenter.py $1 > $1.seg
	echo "  .parsing"
	python Discourse_Parser.py $1.seg
	cp tmp_doc.dis $1.rst
else
	echo "  .skipped (already parsed)"
fi
exit 0
