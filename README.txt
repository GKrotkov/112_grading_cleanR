Files/Folders: 
1) main.rmd: The file that you edit and run to get the graphs
2) utility_functions.R: a bunch of utility functions for cleaning
3) data: a folder of test cases I used when testing the data. 
	There are examples here of clean data sheets and dirty data sheets
	so you can see what template.rmd expects. 

---------------------------------------------------------------------------

Guidelines for feeding in grading sheets:
1) Delete all extraneous columns past the "total" column - the code assumes
that I can take ncol(data), which is screwed up if there's extra data past
the "total" column (even if it's just an average calculation)

2) The data reading/cleaning functions expect that the column titles will have a name
and a point value inside brackets, like "questionName [12]" where questionName is 
worth 12 points. 

---------------------------------------------------------------------------

Instructions for running the 112 grade grapher: 
1) Have installed R  and RStudio 
R download link: (https://www.r-project.org/)
RStudio download link: (https://www.rstudio.com/products/rstudio/download/)

2) Open main.rmd

2.5) Install all the packages in the library code chunk. 
    - Go to "Packages", then click "Install", then type in the name of each package. 
    - Click "Install" and then R will install the package for you. 

3) Edit the variables in the first code chunk appropriately. 
    - "file_path": replace this string with the path to your grade data
    - "start_row": the row (going by 1-indexing) where your data begins.
    - "start_col": the column (going by 1-indexing, so A = 1, B = 2) where
	your data begins. 
    - "ignore_rows": If you want any rows to be skipped, put them as a vector here.
	note: this is 1-indexed considering "start_rows" as row 1
    - "ignore_cols": If you want any cols to be skipped, put them as a vector here.
	note: this is 1-indexed considering "start_cols" as col 1
    - "negative_scores": If this variable is TRUE, scores will be read as negative. 
    - "to_clean": If this variable is TRUE, template.rmd will clean the data that you enter. 
	If this variable is FALSE, template.rmd will assume the data is already cleaned, 
	and just read it in with the default read_xlsx function.

4) Click "knit".

5) There will be a .html file in the folder where you had main.rmd with the output. 