# If you are running this script for the first time, and there is already 
# an .RData file associated with this script, you should skip past step 0a 
# (data call-in, management, and setup) and start with step 0b. 

# If the only files you have are this R script and the csv (raw data) files, 
# you should run Step 0a and skip Step 0b. 

# To avoid having to run step 0a multiple times on the same data, you will, 
# at the end of step 0a, be instructed to save the "workspace" you have 
# created as an .RData file, which can be called into any R session you want 
# to run in the future using Step 0b. You can save your workspace at any point 
# in your analyses to this same .RData file, and when you start up R again, you
# can pick up right where you left off at the last save. I recommend saving
# the workspace at the end of each of your R sessions. 

install.packages('viridis')
install.packages('vegan')

##### Libraries (run this whole section every time, even if you've used the RData file) #####
library(ichthyoliths)
library(doParallel)
library(vegan)
library(viridis)


# if for some reason the ichthyoliths package is NOT installed already, run the following code to install the package from GitHub: 
library(devtools) 
# if devtools isn't installed, run install.packages('devtools'), then load the library
install.packages('devtools')
install_github('esibert/ichthyoliths', force = TRUE)


##### Functions (run this whole section, if you are not loading the RData file) #####


##### Step 0a: Calling in data, calculating disparity, creating data frames for plotting and analysis #####
# Note: if there is already an .RData file associated with this script, 
# you can skip this step adn go to Step 0b: loading the .RData file 

# You may need to set up the working directory for this script. 
setwd('/Users/monicamarion/Desktop/Homework/I606/Star_Husband/R_Files')


### Data we need here are: 
# 1. The morphology dataset
# 2. trait distance csvs

### Morphology-- the codes for the stories
dat_toothmorph <- read.csv('StarHusbandCodes_4-27_2.csv', skip = 0, header = TRUE)
colnames(dat_toothmorph)[5] <- 'ID' #this is a little thing that we need to do to make the code run properly. It sets the ID column number

## set the weights for each trait
# for star husband tale, certain 'sub-features' are downweighted to .5
# their corresponding collumn has a lower number in this list:
weights <- c(1,2,1,.5,.5,1,1,1,1,1,.5,1,1,.5,.5,1,.5,.5,1,1,1,1,2)

## import the trait distance csvs
# they were created on drive but need to be named properly and saved in a good directory
# should be one for every trait, need to be named 'TraitX.csv'
traitset<-import_traits_csvs(csvpath= "/Users/monicamarion/Desktop/Homework/I606/Star_Husband/traitCSV")

##calculate the distances
#subset weights should be false if you're using the standard weights you already set above
#contTraits should be false unless you have numerical value traits
#morphCols is the columns in the morphology csv which have the number code data
toothdist <- distances_clust(morph = dat_toothmorph, traits = traitset, weights = weights, morphCols = c(6:17), subsetWeights = FALSE, contTraits = FALSE)

# Troubleshooting - find the NAs... 
df.na <- subset(toothdist, is.na(toothdist$dist.sum))
write.csv(toothdist, file = "star_husband_dist_weighted.csv")

#list of teeth that broke the function (if any):
unique(df.na[,3])

# Once there are no more NA values, make the distance matrix object to calculate the morphospace
# make distmat
toothdistmat <- distmat(toothdist)

# check the distance matrix
head (toothdistmat)

# write the distance matrix to csv
write.csv(toothdistmat, file = "star_husband_distmat_weighted.csv")


### Clean up the workspace and get rid of unnecessary objects
rm(dat_ecology_fishlist_raw, dat_ecology_fishlist_cleaned, cols.to.remove, noname, taxonomy_df, valid_taxa, rabosky_taxonomy, df.na, traitset, weights) #we won't be using these anymore... 

### Calculate morphospace. For now, lets just use a standard NMDS with 3 dimensions.

NMDS3 <- metaMDS(toothdistmat, k=3, try = 200)
ordiplot(NMDS3, type = 'text')

#add ordinations to morphology matrix for plotting
dat_toothmorph$MDS1 <- NMDS3$points[,1]
dat_toothmorph$MDS2 <- NMDS3$points[,2]
dat_toothmorph$MDS3 <- NMDS3$points[,3]

# Create a data frame for plotting
df.names <- c(colnames(dat_toothmorph)[c(1:31)])
plot_data <- data.frame(matrix(ncol = length(df.names), nrow = 0))
colnames(plot_data) <- df.names

for(i in 1:length(dat_toothmorph[,1]))  {
  morph <- dat_toothmorph[i,]
  morph.cols <- morph[,c(1:31)]
  all.cols <- cbind(morph.cols)
  plot_data <- rbind(plot_data, all.cols)
}

# clean up
rm(all.cols, morph, morph.cols, df.names, i)

##### Starting the analyses! ##### 

# This is an example of a plot you might make with the data available. 

cols <- viridis(length(unique(plot_data$Area)))
plot(plot_data$MDS1, plot_data$MDS2, pch = 16, col = cols[as.factor(plot_data$Area)]) #noe that this isn't very informative because each of hte 54 orders got a color and we can't really tell them apart... 

# we can also plot specific families or orders or ecologies of interest. 
# For example, here I am plotting the MDS1 and MDS2 coordinates for anglerfish and relatives (order = Lophiiformes)
# I have used the "subset" call to pull only the objects with the order being Lophiiformes. I have also given them the point type of 'solid circle' (#16), and the color red. 
plot(plot_data$MDS1, plot_data$MDS2, pch = 16)
points(subset(plot_data, plot_data$order == 'Lophiiformes', select = c(MDS1, MDS2)), pch = 16, col = 'red')

##save plot_data
write.csv(plot_data, file = "starhusband_plot_data_weighted.csv")

for(i in 5:27)  {
  trait <- colnames(plot_data)[i]
  jname <- paste ('plots/trait',trait,'.jpeg', sep='')
  #start making jpegs
  jpeg(jname,
       width = 800, height = 800)
  #need to create a vector from the variable that gets the data we need
  traitdat = as.vector(unlist(c(plot_data[i]))) # I'm sure there's a better way but this works for now
  cols <- magma(length(unique(traitdat)))
  plot(plot_data$MDS1, plot_data$MDS2, pch = 16, cex= 3, col = cols[as.factor(traitdat)])
  
  text(plot_data$MDS1, plot_data$MDS2, labels=plot_data$ID , pos=3)
  legend("bottomleft", 
         legend = levels(as.factor(traitdat)),
         col = cols[(as.factor(traitdat))],
         pch = 16)
  dev.off()
}


# Have fun!! 
