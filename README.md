# Variance Risk Premia in the Interest Rate Swap market 
### Low-Frequency Effects of Economic Announcements on Variance Risk Premia

## 1	Introduction
We analyze the time series and cross-sectional properties of variance risk premia (VRP) in the interest rate swap market. The results presented show that the term
structure of variance risk premia displays non-negligible differences in a low interest rate environment, compared to normal times. Variance risk premia have on average been negative and economically significant during the sample. In a low interest rate environment, the variance risk premium tends to display more frequent episodes where
it switches sign. We extend these findings by exploring the effects of macro-economic annoucments on variance risk premia. 

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
* Python 3.6 with the following libraries (Pandas)
*	Bloomberg Professional Services or Refinitiv (formerly Thomson Reuters) for historical data
*	Matlab system environment with 3 GB of memory

## 3	Code Structure
### 3.1 	Outline
The project code follows a linear order of execution, starting with the `main.m` file. 
```
-> main.m
  -> Temp/INIT.mat
  -> Code/dataReader.m
    -> Code/volGraphs.m 	 
  -> Code/forecastRV.m
    -> Code/vrpCalculation.m
    -> Code/vrpGraphs.m	
  -> Code/macroRegress.m
    -> Code/macroBucket.m
```

### 3.2 	`/Code`
All project code is stored in the `/Code` folder for generating figures and performing analysis.
- **/.../lib/** stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations 

### 3.3 	`/Input`
Folder for all unfiltered, raw input data for financial time series. 

- **yeildCurve.csv** historical timeseries data of the 1y, 5y and 10y UST, taken from the Federal Reserve
- **sp500.xlsx** historical timeseries data of the S&P 500, **last_px** taken from Bloomberg
- **ecoRelease.csv** historical data of economic annoucements, including forecast average, standard deviation, etc.
- **swaptionIV.xlsx** historical timeseries ATM swaption implied volatility, using a black-scholes volatility model  
- **swapRates.xlsx** historical timeseries of USD swap data for select maturities 

### 3.4 	`/Temp`
Folder for storing data files after being read and cleaned of missing/obstructed values.
- **INIT.mat** stores initializing variables for the code base (e.g. root directory)
- **DATA.mat** stores the downloaded data from input files (e.g. swap rates, swaption IV)
- **VRP.mat** stores the computed variance risk premia measures for each tenor and term
- **FSigmaF.mat** stores the daily GARCH(1,1) volatility forecast, including lower and upper bounds 
- **SigA.mat** stores the annualized GARCH(1,1) volatility forecast, including 95% bounds

- **cleanECO.csv** stores cleaned economic annoucment data, storing strictly numerical values from Bloomberg annoucements

### 3.5 	`/Output`
Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.  
- **/.../garch-forecasts/** stores all GARCH forecasts for each swap tenor against implied volatility levels, for each term
- **/.../macro-annoucements/** stores .csv files that perform analysis against economic annoucements (e.g. CPI) 
  - **/.../regressions/** stores coefficients for changes in volatility measures regressed on macro-economic annoucements  
  - **/.../buckets/** stores graphs of changes in volatility measures bucketed by the standard deviation of each economic forecast / interest rate regime
- **/.../autocorrelations/** stores all autocorrelation figures associated with each swaption security's VRP measure

## 4	Running Code
The following steps are neccesary for gathering data, prior to executing the `main.m` file.

Data Fields that are automatically updated
1. Effective Federal Funds Rate, taken from FRED website (stored under variable `fedfunds`)
2. NBER based Recession Indicators for the United States (USRECD) (stored under variable `recessions`)
3. CBOE Volatility Index: VIX (stored under variable `vix`)
4. The U.S. Treasury Yield Curve: 1961 to the Present (stored under variable `yeildCurve`)

Data Fields that are semi-manually updated
1.	Login into your Bloomberg Professional Service account, you will need it to retrieve historical data for the `/Input/` folder. 
2.	Open the files `sp500.xlsx`, `swaptionIV.xlsx`, and `swapRates.xlsx` on your local machine - refreash the worksheets to update the Bloomberg formulas and populate the data fields. *Note if working on a seperate server or cluster, these refreshed worksheets will need to be transfered to the designated workstation*
3.	Download economic annoucement data (found on the **ECO** tab Bloomberg) and export to a `.csv` file name _**ecoRelease.csv**_

You may opt to run the `main.m` file in an interactive environment (IDE) or via terminal 
  ```
  % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
  $ matlab20a-batch-withemail 10 main.m 
  ```
    
## 5	Possible Extensions
* Work on modiyfing the way in which economic calender releases are gathered from Bloomberg. The current process is tedious and limiting to intervals for exportation.  

## 6	Contributors
* [Rajesh Rao](https://github.com/Raj9898) (Sr. Research Analyst 22’)

