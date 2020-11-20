# Variance Risk Premia in the Interest Rate Swap market 

## 1	Introduction
This paper analyzes the time series and cross-sectional properties of variance risk premia (VRP) in the interest rate swap market. The results presented show that the term
structure of variance risk premia displays non-negligible differences in a low interest rate environment, compared to normal times. Variance risk premia have on average been negative and economically significant during the sample. In a low interest rate environment, the variance risk premium tends to display more frequent episodes where
it switches sign.

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
* Python 3.6 with the following libraries (Pandas)
*	Bloomberg Professional Services or Refinitiv (formerly Thomson Reuters) for historical data
*	Matlab system environment with 2 GB of memory

## 3	Code Structure
### 3.1 	Outline
The project code follows a linear order of execution, starting with the `main.m` file. 
```
-> main.m
  -> Temp/INIT.mat
  -> Code/dataReader.m
    -> Code/genTable.m
    -> Code/volGraphs.m 	 
  -> Code/forecastRV.m
    -> Code/vrpPremium.m
      -> Code/vrpGraphs.m	
  -> Code/macroRegress.m
```

### 3.2 	`/Code`
All project code is stored in the `/Code` folder and is responsible for generating figures, graphs and analysis on implied volatility.

### 3.3 	`/Input`
Folder for all unfiltered, raw input data for financial time series. 
- **10yRate.csv** historical timeseries data of the US generic government 10y index rate
- **EFFR.csv** historical timeseries data of the effective fed funds rate
- **ECO_Release.csv** historical data of economic annoucments, including forecast average, standard deviation, etc.
- **VIX.csv** historical timeseries data of the US VIX index
- **swapBlackIV.csv** historical timeseries ATM swaption implied volatility, using a black-scholes volatility model  
- **swapNormalIV.csv** historical timeseries ATM swaption implied volatility, using a normal implied volatility model
- **swapRates.csv** historical timeseries USD swap data for select maturities 

### 3.4 	`/Temp`
Folder for storing data files after being read and cleaned of missing/obstructed values.
- **INIT.mat** stores initializing variables for the code base (e.g. root directory)
- **DATA.mat** stores the downloaded data from input files (e.g. swap rates, swaption IV)
- **VRP.mat** stores the computed variance risk premia measures for each tenor and term
- **FSigmaF.mat** stores the daily GARCH(1,1) volatility forecast, including lower and upper bounds 
- **SigA.mat** stores the annualized GARCH(1,1) volatility forecast, including 95% bounds
- **cleanECO.csv** stores cleaned economic annoucment data, storing striclty numerical values

### 3.5 	`/Output`
Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.  
- **/.../garchForecasts/** stores all GARCH forecasts for each swap tenor against implied volatility levels, for each term
- **/.../MacroRegressions/** stores .csv files for each swaption security VRP measures, regressed against economic annoucements (e.g. CPI) 
  - **/.../ivTermStruct/** stores term structures of implied volatility regression coefficients 
  - **/.../rvTermStruct/** stores term structures of realized volatility regression coefficients 
  - **/.../vrpTermStruct/** stores term structures of variance risk premia regression coefficients 
  - **/.../vrpBuckets/** stores graphs of changes in VRP bucketed by the standard deviation of each economic forecast
  - **/.../vrpInterestBuckets/** extends the bar graphs stored in `vrpBuckets` by segmenting them by low/high interest rate regime  
- **/.../Autocorrelations/** stores all autocorrelation figures associated with each swaption security's VRP measure

## 4	Running Code
All of the code files are executed from the `main.m` file. The following steps are neccesary for gathering data, prior to execution.

1.	Open Bloomberg Professional Service or Refinitiv Datastream, you will need to retrieve historical data and store them in the `/Input/` folder. All data ranges should coincide with one another, such that their time horizons match and are aranged in ascending order (from oldest to earliest date, e.g. 1996-2020). 
    - Download the US treasury Government 10 index (**USGG10YR Index**) and export to a `.csv` file name _**TreasuryRate.csv**_
    - Download US swap rate data for maturities 2y, 5y, 10y (**e.g. USSW10 Curncy**) and export to a `.csv` file named _**swapRates.csv**_   
    - Download US ATM swap implied volatility data for swap tenors 2y, 5y and 10y and expiry 3m, 6m, 12m and 24m 
        - Using a Black-Scholes model (**e.g. USSV0110 Curncy**) and exporting IV data to _**swapBlackIV.csv**_
        - Using a Normal distribution model (**e.g. USSN0110 Curncy**) and exporting IV data to _**swapNormalIV.csv**_
    - Download historical US VIX index data and export to a `.csv` file name _**VIX.csv**_
    - Download economic annoucement data (found on the **ECO** tab Bloomberg) and export to a `.csv` file name _**ECO_Release.csv**_

2.  Download the Effective Federal Funds Rate ([EFFR](https://fred.stlouisfed.org/series/EFFR)) from the FRED website over the identical range specified before. 

3.	You may opt to run the `main.m` file in an interactive environment (IDE) or via terminal 
    ```
    % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
    $ matlab20a-batch-withemail 10 main.m 
    ```
    
## 5	Possible Extensions
* Work on automatically downloading Bloomberg data for specific tickers 
* Try to automate EFFR data pulls from FRED on Matlab

## 6	Contributors
* [Rajesh Rao](https://github.com/Raj9898) (Research Analyst 22’)

