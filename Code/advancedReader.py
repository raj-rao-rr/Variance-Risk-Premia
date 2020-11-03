#!/apps/Anaconda3-2019.03/bin/python 
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  3 10:45:17 2020

@author: Rajesh Rao
"""

##########################################################################
# PACKAGE IMPORTS
##########################################################################

# text/string manipulation re-gex 
import re

import pandas as pd 


baseDirectory = '/home/rcerxr21/DesiWork/VRP_GIT'
inputDirectory = baseDirectory + '/Input/'
tempDirectory = baseDirectory + '/Temp/'


# %% Economic Data Annoucements 

# reading in economic annoucements from Blommberg
ecoAnnounce = pd.read_csv(inputDirectory + 'ECO_release.csv')

def accountsFix(elm):
    """
    Removes non-numeric characters from elements within reported data 
    :param: elm = data from pandas dataframe, supports many types    ...: import r
    
    e.g.
        [In]: '3.4'
        [Out]: '3.4'
        
        [In]: '73.6k'
        [Out]: '73.6'
        
        [In]: '-$113.5b'
        [Out]: '-113.5'
        
        [In]: '-$113.5b'
        [Out]: '-113.5'
    """
    try:
        return re.sub("[^0-9|.|-]", "", elm)
        
    except TypeError:
        return elm

# fix the economic data points, extracting only numeric values
ecoAnnounce['SurvM'] = ecoAnnounce['SurvM'].apply(accountsFix)
ecoAnnounce['SurvA'] = ecoAnnounce['SurvA'].apply(accountsFix)
ecoAnnounce['SurvH'] = ecoAnnounce['SurvH'].apply(accountsFix)
ecoAnnounce['SurvL'] = ecoAnnounce['SurvL'].apply(accountsFix)
ecoAnnounce['Actual'] = ecoAnnounce['Actual'].apply(accountsFix)
ecoAnnounce['Prior'] = ecoAnnounce['Prior'].apply(accountsFix)
ecoAnnounce['Revised'] = ecoAnnounce['Revised'].apply(accountsFix)

# store the macro-variables to temp folder
ecoAnnounce.to_csv(tempDirectory+'cleanECO.csv')

# %%