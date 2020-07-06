# scripts/prepare_data.R
# script to run checks on csv data input to get it ready to make distance matrix

## input data required: 
# 1. The story codes dataset
# 2. trait distance csvs (one trait matrix for every story trait)
# 3. weights csv

#there should be a check to make sure no metadata is after traits-- and all traits match up with a traitset
#check to see if any of the codes are outside of the trait matrix frame
#weights also needs to match up with number of traits