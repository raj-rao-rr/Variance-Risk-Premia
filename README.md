# Variance Risk Premia in the Interest Rate Swap market 
### Low-Frequency Effects of Economic Announcements on Variance Risk Premia

## 1	Introduction
We analyze the time series and cross-sectional properties of variance risk premia (VRP) in the interest rate swap market. The results presented show that the term
structure of variance risk premia displays non-negligible differences in a low interest rate environment, compared to normal times. Variance risk premia have on average been negative and economically significant during the sample. In a low interest rate environment, the variance risk premium tends to display more frequent episodes where
it switches sign. We extend these findings by exploring the effects of macro-economic announcements on variance risk premia. 

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
* Python 3.6 with the following libraries (Pandas)
*	Bloomberg Professional Services for historical data
*	Matlab system environment with at least 3 GB of memory

## 3	Code Structure

### 3.1 	`/Code`
All project code is stored in the `/Code` folder for generating figures and performing analysis.
- **/.../lib/** stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations 

### 3.2 	`/Input`
Folder for all unfiltered, raw input data for financial time series. 

- **yeildCurve.csv** historical timeseries data of the 1y, 5y and 10y UST, taken from the Federal Reserve
- **sp500.xlsx** historical timeseries data of the S&P 500, **last_px** taken from Bloomberg
- **ecoRelease.csv** historical data of economic announcements, including forecast average, standard deviation, etc.
- **swaptionIV.xlsx** historical timeseries ATM swaption implied volatility, using a Black-Scholes volatility model  
- **swapRates.xlsx** historical timeseries of USD swap data for select maturities 

### 3.3 	`/Temp`
Folder for storing data files after being read and cleaned of missing/obstructed values.
- **DATA.mat** stores the downloaded data from input files (e.g. swap rates, swaption implied volatility)
- **FSigmaF.mat** stores the daily GARCH(1,1) volatility forecasts, including lower and upper bounds 
- **SigA.mat** stores the annualized GARCH(1,1) volatility forecasts, including 95% bounds
- **cleanECO.csv** stores cleaned economic announcement data, storing strictly numerical values from Bloomberg announcements

### 3.4 	`/Output`
Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.  
- **/.../garch-forecasts/** stores all GARCH forecasts for each swap tenor against implied volatility levels, for each term
- **/.../macro-announcements/** stores .csv files that perform analysis against economic announcements (e.g. CPI) 
  - **/.../regressions/** stores coefficients for changes in volatility measures regressed on macro-economic announcements  
  - **/.../buckets/** stores graphs of changes in volatility measures bucketed by the standard deviation of each economic forecast / interest rate regime
- **/.../autocorrelations/** stores all autocorrelation figures associated with each swaption security's VRP measure

## 4	Running Code
The following steps are necessary for gathering data, prior to executing the `main.m` file.

**Data Fields that are automatically updated from HTML connections**
1. Effective Federal Funds Rate, taken from FRED website (stored under variable `fedfunds`)
2. NBER based Recession Indicators for the United States (USRECD), taken from FRED website (stored under variable `recessions`)
3. CBOE Volatility Index: VIX, taken from FRED website (stored under variable `vix`)
4. The U.S. Treasury Yield Curve: 1961 to the Present, taken from Federal Reserve website (stored under variable `yeildCurve`)

**Data Fields that are semi-manually updated**
1.	Login into your Bloomberg Professional Service account, you will need it to retrieve historical data. 
2.	Open the following excel files `sp500.xlsx`, `swaptionIV.xlsx`, and `swapRates.xlsx` on your local machine. Go to the Bloomberg tab on Excel and click the **Refresh Worksheets** icon to update the Bloomberg formulas, populating the data fields. *Note if working on a separate server or cluster, these refreshed worksheets will need to be transferred to the designated workstation*
3.	On your Bloomberg terminal go to the ECO tab and begin downloading the requested economic announcement data to a `.csv` file name _**ecoRelease.csv**_. Due to the interval restrictions imposed by Bloomberg for the exportation of the data, you will need to export multiple times per defined intervals.
4. Once all data has been updated you are free to run the entire project base. You may opt to run the `main.m` file in a Matlab interactive session or via terminal on your local machine or HPC cluster.

    ```
    % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
    $ matlab20a-batch-withemail 10 main.m 
    ```
    
## 5	Possible Extensions
* Work on modifying the way in which economic calendar releases are gathered from Bloomberg. The current process is tedious and limiting to intervals for exportation.  

## 6	Contributors
* [Rajesh Rao](https://github.com/Raj9898) (Sr. Research Analyst 22’)

