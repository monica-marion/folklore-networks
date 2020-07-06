# scripts/network_basics.py
# uses distance matrix to build network and provide basic network stats

## input data required: dist_mat.pkl

import networkx as nx
import numpy as np
import pandas as pd

## build the network
# import the distance matrix csv
import csv
distmat = pd.read_csv('Star_Husband/R_Files/star_husband_distmat_weighted.csv')
# get rid of extra column
del distmat['Unnamed: 0']

# subtract each value from one so that instead of distances counting down to 0 they count up to 1
for i in range(82):
    for j in range(1,83):
        distmat.at[i,str(j)] = 1-distmat.at[i,str(j)]
print(distmat)
#(identical stories should now have a pair distance of 1)

# import the metadata and codes (morphology) csv to get node labels
morph = pd.read_csv('Star_Husband/R_Files/StarHusbandCodes_4-29.csv')

##setting the node attributes
# starting with title, area, STTtype

title = morph[['Title']]
area = morph[['Area']]
sttype = morph [['STType']]
a = morph [['A']]
b = morph [['B']]
c = morph [['C']]
c1 = morph [['C1']]
c2 = morph [['C2']]
d= morph [['D']]
e = morph [['E']]
f = morph [['F']]
g = morph [['G']]
h = morph [['H']]
h1 = morph [['H1']]
traiti = morph [['I']]
j = morph [['J']]
j1 = morph [['J1']]
j6 = morph [['J6']]
k1 = morph [['K1']]
k3 = morph [['K3']]
k7 = morph [['K7']]
l = morph [['L']]
m1 = morph [['M1']]
m3 = morph [['M3']]
m = morph [['M']]
n = morph [['N']]

### make the empty graph
G=nx.Graph()

##add nodes to network, with attribute for label
for p in range(1,87):
    G.add_node(p , title = title.iloc[(p-1),0], area = area.iloc[(p-1),0], sttype = str(sttype.iloc[(p-1),0]),
              a=str(a.iloc[(p-1),0]), b=str(b.iloc[(p-1),0]), c=str(c.iloc[(p-1),0]), c1=str(c1.iloc[(p-1),0]), d=str(d.iloc[(p-1),0]),
               e=str(e.iloc[(p-1),0]), f=str(f.iloc[(p-1),0]), g=str(g.iloc[(p-1),0]), h=str(h.iloc[(p-1),0]), h1=str(h1.iloc[(p-1),0]),
               i=str(traiti.iloc[(p-1),0]), j=str(j.iloc[(p-1),0]), j1=str(j1.iloc[(p-1),0]), j6=str(j6.iloc[(p-1),0]), k1=str(k1.iloc[(p-1),0]),
               k3=str(k3.iloc[(p-1),0]), k7=str(k7.iloc[(p-1),0]), l=str(l.iloc[(p-1),0]), m1=str(m1.iloc[(p-1),0]), m3=str(m3.iloc[(p-1),0]),
               m=str(m.iloc[(p-1),0]), n=str(n.iloc[(p-1),0]))

## add edges, using weights from distmat
#reset G
for edge in G.edges:
    G.remove_edge(edge[0],edge[1])

# loop over all the node combinations
## NEEDS TO ADAPT TO DIFFERENT NUMBERS OF INPUT DATA
for i in range (1,87):
    for j in range (i,87):
# create a threshold similarity cutoff for building edges
        if distmat.at[i-1,str(j)]> 0.8:
            G.add_edge(i,j, weight = distmat.at[i-1,str(j)])

# matplotlib to draw it
%matplotlib inline
import matplotlib.pyplot as plt

plt.figure()
nx.draw(G)

# show the figure
plt.show()

## write to gml so I can play with it more in Gephi
nx.write_gml(G,'/Users/monicamarion/Desktop/Homework/I606/Star_Husband/star_husband_network_5-8_labeled.gml')

# calculating betweenness
nx.betweenness_centrality (G)
