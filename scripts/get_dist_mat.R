# scripts/get_dist_mat.R
# takes checked story data as input and produces a distance matrix that records distance between each story variant
## input data required: 
# 1. The story codes dataset
# 2. trait distance csvs (one trait matrix for every story trait)
# 3. weights csv

# install the ichthyoliths package from GitHub by first installing devtools to get github install function:
install.packages('devtools')
library(devtools) 

install_github('esibert/ichthyoliths', force = TRUE)

# install libraries
library(ichthyoliths)
library(doParallel)

# You may need to set up the working directory for this script?
# setwd('/Users/monicamarion/Desktop/Homework/I606/Star_Husband/R_Files')

### import the "Morphology"-- the codes for the stories
dat_storycodes <- read.csv(SnakeMakeInput[0], skip = 0, header = TRUE)

#from the story code csv you'll need to take a few other variables for the distance function to work
#morphCols is the columns in the story code csv which have the number code data
startcol = which( colnames(dat_storycodes)=="ID" ) + 1
endcol = ncol(dat_storycodes)
morphCols = c(startcol:endcol)

## import the weights for each trait
weights <- read.csv(SnakeMakeInput[1], skip=0, header = FALSE)

## import the trait distance csvs
# should be one for every trait, need to be named 'TraitX.csv'
traitset<-import_traits_csvs(csvpath= "traitCSV")

##calculate the distances
#subset weights should be false if you're using the weights you already set above
#contTraits should be false unless you have continuous numerical value traits (as opposed to arbitrary numberings with a trait matrix to delimit the distances between them)
distances <- distances_clust(morph = dat_storycodes, traits = traitset, weights = weights, morphCols = morphCols, subsetWeights = FALSE, contTraits = FALSE)

# Once there are no more NA values, make the distance matrix object
distmat <- distmat(distances)

# write the distance matrix to csv
write.csv(distmat, file = "distmat.csv")
