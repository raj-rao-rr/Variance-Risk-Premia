# Variance Risk Premia in the Interest Rate Swap market 

## 1	Introduction
The variance risk premia (VRP) measures the amount investors are willing to pay during “normal times” in order to insure against high realized interest rate volatility. Conversely, to the option seller, it reflects the compensation demanded for taking the risk of incurring significant losses in periods when realized volatility increases significantly and unexpectedly. We define VRP as the difference between expected realized future variances and risk neutral variances, taking a GARCH(1,1) model to forecast realized variances and the ATM swaption implied volatility as a proxy for the risk neutral variances. 

## 2	Software Dependencies
*	MATLAB 2020a with Econometrics, Optimization, Financial Toolboxes
*	Bloomberg Professional Services for historical data
*	Refinitiv (formerly Thomson Reuters) Datastream for historical data
*	RAN environment with 10 GB of memory

## 3	Code Structure
### 3.1 	Outline
The code base follows a linear order of execution, starting with the `main.m` file. 

```
> main.m
  ∟	Temp/INIT.mat
  ∟	Code/dataReader.m
        →	Temp/DATA.mat 
  ∟	Code/genTable.m
        →	descriptiveStats.csv
  ∟	Code/volGraphs.m 	 
        →	black_normal_vol.jpg
        →	Output/swaption_implied_volatilities.jpg
        →	Output/swaption_iv_term_structure.jpg
        →	Output/vix_vs_iv.jpg
  ∟	Code/forecastRV.m
        →	Temp/FSigmaF.mat	
        →	Temp/SigA.mat
  ∟	Code/vrpPremium.m
        →	Temp/VRP.mat
  ∟	Code/vrpGraphs.m	
        →	Output/GARCH_Forecasts/
        →	Output/Autocorrelations/
        →	Output/variance_risk_premia.jpg
        →	Output/vrp_vs_vix.jpg
```

### 3.2 	`/Code`
All project code is stored in the `/Code` folder, and is responsible for forecasting annualized volatility, generating figures and performing regression on select risk premia measure.

### 3.3 	`/Input`

`10yRate.csv`
downloaded historical data from the US generic government 10y index rate

`VIX.csv`
downloaded historical data from the US VIX index

`swapBlackIV.csv`
downloaded historical ATM swaption implied volatility, using a black-scholes implied volatility model  

`swapNormalIV.csv`
downloaded historical ATM swaption implied volatility, using a normal implied volatility model

`swapRates.csv`
downloaded historical USD swap data for select maturities 

### 3.4 	`/Temp`

`INIT.mat`
stores initializing variables for the code base (e.g. root directory)

`DATA.mat`
stores the downloaded data from input files (e.g. swap rates, swaption IV)

`VRP.mat`
stores the computed variance risk premia measures for each tenor and term

`FSigmaF.mat`
stores the daily GARCH(1,1) volatility forecast, including lower and upper bounds 

`SigA.mat`
stores the annualized GARCH(1,1) volatility forecast, including 95% bounds

### 3.5 	`/Output`
All graphs and tables are to be stored in the `/Output` folder or select sub-folders (e.g. `/GARCH_Forecasts`)

## 4	Running Code
All of the code is executed via the `main.m` file, with the following steps.

1.	Open the `main.m` file and change the variable root_dir to reflect the proper directory where the code base is stored. 

    ```
    % %    e.g. directory of file is stored in /home/rcerxr21/DesiWork/VRP
    root_dir = [filesep ‘home’ filesep ‘rcerxr21’ filesep ‘DesiWork’ filesep ‘VRP’] 
    ```
2.	Open Bloomberg Professional Service, you will need to retrieve historical data and store them in the `/Input`. 
    1. Download the US treasury Government 10 index (USGG10YR Index) and export to a .csv file name "10yRate.csv"
    2. Download US swap rate data for maturities 2y, 5y, 10y and export to a `.csv` file (e.g. USSW2 Curncy) named "swapRates.csv"  
    3. Download US ATM swap implied volatility data for tenors 2y, 5y and 10y and terms 3m, 6m, 12m and 24m 
    4. Using a Black-Scholes model (e.g. USSV0110 Curncy) and exporting IV data to "swapBlackIV.csv"
    5. Using a Normal distribution model (e.g. USSN0110 Curncy) and exporting IV data to "swapNormalIV.csv"
    6. Downloaded historical US VIX index data for the 3m, 6m and 1y term (e.g. VIX3M Index) and export to a `.csv` file name "VIX.csv"
3.	Run the `main.m` file in the RAN terminal, you may opt to run it in an interactive environment or in batch

    ```
    % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
    $ matlab20a-batch-withemail 10 main.m 
    ```
## 5	Possible Extensions
* Work on automatically pulling Bloomberg data over a given range when computing VRP measures. 

## 6	Contributors
* Rajesh Rao (Research Analyst 22’)

