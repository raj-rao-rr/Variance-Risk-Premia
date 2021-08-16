# Low-Frequency Effects of Economic Announcements on VRP

## 1	Introduction
We analyze the time series and cross-sectional properties of variance risk premia (VRP) in the interest rate swap market. The results presented show that the term structure of variance risk premia displays non-negligible differences in a low interest rate environment, compared to normal times. Variance risk premia have on average been negative and economically significant during the sample. In a low interest rate environment, the variance risk premium tends to display more frequent episodes where it switches sign. We extend these findings by exploring the effects of macro-economic announcements on variance risk premia. 

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
*	Bloomberg Professional Services for historical data
*	MATLAB system environment with at least 3 GB of memory

## 3	Code Structure

### 3.1 	`/Code`
All project code is stored in the `/Code` folder for generating figures and performing analysis. Refer to the headline comment string in each file for a general description of the purpose of the script in question. 
- **/.../lib/** stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations 

### 3.2 	`/Input`
Folder for all unfiltered, raw input data for financial time series. 

- **yeildCurve.csv** historical timeseries data of the 1y, 5y and 10y UST, taken from the Federal Reserve
- **sp500.xlsx** historical timeseries data of the S&P 500, **last_px** taken from Bloomberg
- **bloomberg_economic_releases.csv** historical data of economic announcements, including forecast average, standard deviation, etc.
- **swaptionIV.xlsx** historical timeseries ATM swaption implied volatility, using a Black-Scholes volatility model  
- **swapRates.xlsx** historical timeseries of USD swap data for select maturities 

### 3.3 	`/Temp`
Folder for storing data files after being read and cleaned of missing/obstructed values.

- **DATA.mat** stores the downloaded data from input files (e.g., swap rates, swaption implied volatility)
- **FSigmaF.mat** stores the daily, not annualized GARCH(1,1) volatility forecasts, including 95% lower and upper bounds 
- **SigA.mat** stores the annualized GARCH(1,1) volatility forecasts, including 95% lower and upper bounds 

### 3.4 	`/Output`
Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.  
- `/.../autocorrelations/` stores all autocorrelation figures associated with each swaption security's VRP measure. For a detailed overview of the code responsible for constructing these measures refer to `vrpGraphs.m` under the header **Figure (5) Autocorrelation Function for Variance Risk Premia**.

- `/.../garch-forecasts/` stores all GARCH forecasts for each swap tenor against implied volatility levels, for each term. For a detailed overview of the code responsible for constructing these measures refer to `vrpGraphs.m` under the header **Figure (3) Swaption Implied Vol vs. Forecasted Real Vol**.

- `/.../macro-announcements/` stores .csv files that perform analysis against economic announcements (e.g., CPI) 
  - `/.../buckets/` stores graphs of changes in volatility conditioned by the standard deviation of each economic forecast and interest rate regime. For more detailed overview of the code responsible for constructing these measures refer to `macroBucket.m`. 
  - `/.../regressions/` stores coefficients for changes in volatility measures regressed on macro-economic announcements. For more detailed overview of the code responsible for constructing these measures refer to `macroRegress.m`.   
  - `/.../responses/` stores graphs illustrating cumulative returns against macroeconomic variables. For more detailed overview of the code responsible for constructing these measures refer to `macroAggregate.m`.   

## 4	Running Code
The following steps are necessary for gathering data, prior to executing the `main.m` file.

**Data Fields that are automatically updated from HTML connections**
1. [Effective Federal Funds Rate](https://fred.stlouisfed.org/series/FEDFUNDS), taken from FRED website (stored under variable `fedfunds`)
2. [NBER based Recession Indicators for the United States (USRECD)](https://fred.stlouisfed.org/series/USRECD), taken from FRED website (stored under variable `recessions`)
3. [CBOE Volatility Index: VIX](https://fred.stlouisfed.org/series/VIXCLS), taken from FRED website (stored under variable `vix`)
4. [The U.S. Treasury Yield Curve: 1961 to the Present](https://www.federalreserve.gov/pubs/feds/2006/200628/200628abs.html), taken from Federal Reserve website (stored under variable `yeildCurve`)

**Data Fields that are semi-manually updated**
1.	Login into your Bloomberg Professional Service account, you will need it to retrieve historical data. 
2.	Open the following excel files `sp500.xlsx`, `swaptionIV.xlsx`, and `swapRates.xlsx` on your local machine. Go to the Bloomberg tab on Excel and click the **Refresh Worksheets** icon to update the Bloomberg formulas, populating the data fields. *Note if working on a separate server or cluster, these refreshed worksheets will need to be transferred to the designated workstation*
3.	To update the data series entitled `bloomberg_economic_releases.csv`, refer this [repo](https://github.com/raj-rao-rr/BBG-ECO-EXCEL). Simply transfer the `Output` series from the BBG-ECO-EXCEL project to the `Input` folder of this repo. 
4. Once all data has been updated you are free to run the entire project base. You may opt to run the `main.m` file in a MATLAB interactive session or via terminal on your local machine or HPC cluster.

    ```
    % %    e.g., running code via batch on the FRBNY RAN HPC Cluster
    $ matlab20a-batch-withemail 5 main.m 
    ```
    
## 5	Possible Extensions
* Work on potentially updating Bloomberg data without manually opening files.  

## 6	Contributors
* [Rajesh Rao](https://github.com/raj-rao-rr) (Sr. Research Analyst)
