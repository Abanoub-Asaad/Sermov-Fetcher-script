#!/bin/bash

#================================================================
# Author:   	  Abanoub Asaad			   		#
# Version:   	  0.1				          	#
# My GitHub:	  https://github.com/Abanoub-Asaad    	        #
# Note:		  This script depends on IMDb site 		#
#===============================================================#

# Print 
tput setaf 4; echo "========================================================================"
echo "Hi, Type the name of the Movie or Series you want to search about"
tput setaf 2;

# Read the movie or series name
read searchText
tput setaf 4; echo "========================================================================"
tput setaf 7;


# Download the result page for the specified search
wget -O "$searchText-search.html" "http://www.imdb.com/find?q=$searchText"


# Run another regex to get the movie titles div and write the data to another file to avoid link filename mismatch
sed -e '/Titles<\/h3>/,/findMoreMatches/!d' "$searchText-search.html" > "partialContentFile.txt"


# Get the result movies' links from html file
grep -E -o "\/title\/[a-zA-Z0-9]+\/" "partialContentFile.txt" > "filesToDownload.txt"


# Get the result movies' names
grep -P -o "(?<=>)([a-zA-Z0-9&: _-]+)(?=<\/a>[\(\) a-zA-Z0-9 _-]*\([0-9]+\))" "partialContentFile.txt" > "movieNames.txt"


# Get the result movies' years
grep -P -o "(?<=<\/a> )(\([0-9]+\))(?= )" "partialContentFile.txt" > "movieYears.txt"


# Make a new file to store the movie names and years
> "movieNameYear.txt"


# Use different file descriptors to read from and work with two files
while read -r -u3 movieName; read -r -u4 movieYear;
do
 echo "$movieName" "$movieYear" >> "movieNameYear.txt"
done 3<movieNames.txt 4<movieYears.txt



# Read from the file that was written to
j=0

while read line
do
	repline=$line
	
	# Replace file name spaces with underscore
	fixedline=${repline// /_}	
	movieNameYear_array[j]=$fixedline
	#echo ${movieNameYear_array[j]}
	j=$(( j + 1 ))
done < "movieNameYear.txt"



# Since the link are duplicated due 
moviefoldername=movies
mkdir $moviefoldername

i=0
k=0

while read line
do
	temp=$(( $i % 2 )) 
	
	# Temporary fix when file name or file year was not extracted correctly 
	if [ $j -eq $k ]; then
		break
	fi
	
	if [ $temp -eq 0 ]; then
		
		# Each of the resultant files are downloaded here, Now read and perform rating extraction from it
		wget -O "$moviefoldername/${movieNameYear_array[k]}" "http://www.imdb.com$line"
		k=$(( k + 1 ))

	fi

	i=$(( i + 1 ))

done < "filesToDownload.txt"



# Now print the files in the movies directory
tput setaf 4; echo "===============================================" 

for fileName in `ls $moviefoldername/`
do
	#echo "$fileName"
	
	# Sample rating tag block
	#<span itemprop="ratingValue">6.4</span></strong>
	
	tput setaf 1; echo "Original name and Year of Release: "
	tput setaf 2; echo "$fileName"	
	tput setaf 1; echo "Rating: ";
	tput setaf 2;
	grep -P -o "(?<=<span itemprop=\"ratingValue\">)([0-9][.]?[0-9]?)(?=<\/span><\/strong>)" "$moviefoldername/$fileName"

	#<meta name="description" content="Directed by Sam Raimi.  With Tobey Maguire, Kirsten Dunst, Willem Dafoe, James Franco.
	#When bitten by a genetically modified spider, a nerdy, shy, and awkward high school student gains spider-like abilities that he
	#eventually must use to fight evil as a superhero after tragedy befalls his family." />

	tput setaf 1; echo "Director, Stars and Storyline: " 
	tput setaf 2;
        grep 'meta name="description" content="' "$moviefoldername/$fileName"  | cut -d '"' -f4

	tput setaf 4; echo "===============================================" 

done
	


tput setaf 7;

# Make directory to put in it all related files
if [[ -d Sermov\ Fetcher\ related ]]
then
    rm -r Sermov\ Fetcher\ related
    mkdir Sermov\ Fetcher\ related
else
    mkdir Sermov\ Fetcher\ related
fi

# Move all related files to directory "Sermov_Fetcher_related"
mv "$searchText-search.html" Sermov\ Fetcher\ related
mv "partialContentFile.txt" Sermov\ Fetcher\ related
mv "filesToDownload.txt" Sermov\ Fetcher\ related
mv "movieNames.txt" Sermov\ Fetcher\ related
mv "movieYears.txt" Sermov\ Fetcher\ related
mv "movieNameYear.txt" Sermov\ Fetcher\ related
mv movies Sermov\ Fetcher\ related

# rm -r Sermov\ Fetcher\ related

