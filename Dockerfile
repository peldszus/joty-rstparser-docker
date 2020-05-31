FROM java:7

MAINTAINER Andreas Peldszus "andreas.peldszus@posteo.de"

# Update the python2.7 environment used here
RUN apt-get update \
	&& apt-get install -y --force-yes python python-dev python-pip python-virtualenv

# Installs python packages
RUN apt-get update \
	&& apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran \
	&& pip install numpy==1.11.1 \
	&& pip install scipy==0.17.1 scikit-learn==0.17.1 nltk==3.2.1

# Download and install discourse parser distribution
RUN wget http://alt.qcri.org/tools/discourse-parser/releases/current/Discourse_Parser_Dist.tar.gz \
	&& tar -xf Discourse_Parser_Dist.tar.gz \
    && rm -rf Discourse_Parser_Dist.tar.gz

# Install wordnet
RUN apt-get update && apt-get -y install wordnet-base
ENV WNHOME=/usr/share/wordnet
ENV WNSEARCHDIR=/usr/share/wordnet
RUN python -c 'import nltk; nltk.download("wordnet")'

# Installs WordNet Query Script
RUN cd Discourse_Parser_Dist/Tools \
	&& tar -xf WordNet-QueryData-1.49.tar.gz \
	&& cd WordNet-QueryData-1.49/ \
	&& perl Makefile.PL && make && make test && make install \
    && cd .. && rm -rf WordNet-QueryData-1.49 WordNet-QueryData-1.49.tar.gz

# Re-train sklearn segmenter model
ADD retrain.patch .
RUN patch Discourse_Parser_Dist/Discourse_Segmenter.py < retrain.patch
ADD test.txt Discourse_Parser_Dist/
RUN cd Discourse_Parser_Dist \
	&& python Discourse_Segmenter.py --train test.txt

# Add and test convenience script
ADD parse.sh Discourse_Parser_Dist/
RUN cd Discourse_Parser_Dist \
	&& ./parse.sh test.txt

# Clean up
RUN rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
