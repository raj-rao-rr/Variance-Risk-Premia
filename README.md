# Variance Risk Premia in the Interest Rate Swap market 

## 1	Introduction
The variance risk premia (VRP) measures the amount investors are willing to pay during “normal times” in order to insure against high realized interest rate volatility. Conversely, to the option seller, it reflects the compensation demanded for taking the risk of incurring significant losses in periods when realized volatility increases significantly and unexpectedly. We define VRP as the difference between expected realized future variances and risk neutral variances, taking a GARCH(1,1) model to forecast realized future variances and the ATM swaption implied volatility as a proxy for the risk neutral variances. 

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial
* Python 3.6 with the followinh libraries (Pandas)
*	Bloomberg Professional Services or Refinitiv (formerly Thomson Reuters) for historical data
*	System environment with 2 GB of memory

## 3	Code Structure
### 3.1 	Outline
The code base follows a linear order of execution, starting with the `main.m` file. 

- main.m
  - Temp/INIT.mat
  - Code/dataReader.m
    - advancedReader.py
      - Temp/DATA.mat 
  - Code/genTable.m
    - table1.csv
  - Code/volGraphs.m 	 
    - Output/figure1.jpg
    - Output/swaption_iv_term_structure.jpg
    - Output/vix_vs_iv.jpg
  - Code/forecastRV.m
    - Temp/FSigmaF.mat	
    - Temp/SigA.mat
  - Code/vrpPremium.m
    - Temp/VRP.mat
  - Code/vrpGraphs.m	
    - Output/garchForecasts/
    - Output/figure4.jpg
    - Output/Autocorrelations/
    - Output/figure6.jpg
  - Code/vrpPremium.m
    - Output/MacroRegressions/

### 3.2 	`/Code`
All project code is stored in the `/Code` folder, and is responsible for forecasting annualized volatility, generating figures and performing regression on select risk premia measure.

### 3.3 	`/Input`

- **10yRate.csv** downloaded historical data from the US generic government 10y index rate
- **VIX.csv** downloaded historical data from the US VIX index
- **swapBlackIV.csv** downloaded historical ATM swaption implied volatility, using a black-scholes implied volatility model  
- **swapNormalIV.csv** downloaded historical ATM swaption implied volatility, using a normal implied volatility model
- **swapRates.csv** downloaded historical USD swap data for select maturities 

### 3.4 	`/Temp`

- **INIT.mat** stores initializing variables for the code base (e.g. root directory)
- **DATA.mat** stores the downloaded data from input files (e.g. swap rates, swaption IV)
- **VRP.mat** stores the computed variance risk premia measures for each tenor and term
- **FSigmaF.mat** stores the daily GARCH(1,1) volatility forecast, including lower and upper bounds 
- **SigA.mat** stores the annualized GARCH(1,1) volatility forecast, including 95% bounds

### 3.5 	`/Output`
All graphs and tables are stored in the `/Output` folder or within select sub-folders with figure identifiers referencing their location in the paper 
- **/garchForecasts** stores all GARCH forecasts for each swap tenor, across term structure
- **/MacroRegressions** stores .csv files for each swaption security VRP measures, regressed against macro-economic variables
- **/Autocorrelations** stores all autocorrelation figures associated with each swaption security VRP measures

## 4	Running Code
All of the code files are executed from the `main.m` file. The following steps below illustrate the neccesary preprations, prior to execution of the `main.m` file.

1.	Open the `main.m` file and change the variable `root_dir` to reflect the directory where the local repository is stored. 

    ```
    % %    e.g. directory of file is stored in /home/rcerxr21/DesiWork/VRP
    root_dir = [filesep ‘home’ filesep ‘rcerxr21’ filesep ‘DesiWork’ filesep ‘VRP’] 
    ```
2.	Open Bloomberg Professional Service or Refinitiv Datastream, you will need to retrieve historical data and store them in `/Input`. All data ranges should coincide with one another, such that their time horizons match and are aranged in ascending order (from latest to earliest date, e.g. 1996-2020). 
    1. Download the US treasury Government 10 index (USGG10YR Index) and export to a `.csv` file name _**TreasuryRate.csv**_ 
    2. Download US swap rate data for maturities 2y, 5y, 10y (e.g. USSW10 Curncy) and export to a `.csv` file named _**swapRates.csv**_   
    3. Download US ATM swap implied volatility data for swap tenors 2y, 5y and 10y and expiry 3m, 6m, 12m and 24m 
        1. Using a Black-Scholes model (e.g. USSV0110 Curncy) and exporting IV data to _**swapBlackIV.csv**_
        2. Using a Normal distribution model (e.g. USSN0110 Curncy) and exporting IV data to _**swapNormalIV.csv**_
    4. Downloaded historical US VIX index data and export to a `.csv` file name _**VIX.csv**_
3.	Run the `main.m` file in the RAN terminal, you may opt to run it in an interactive environment or in a batch terminal 

    ```
    % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
    $ matlab20a-batch-withemail 10 main.m 
    ```
## 5	Possible Extensions
* Work on automatically downloading Bloomberg data over a given range for specific tickers (e.g. USSV0110 Curncy = ATM Swaption 1y10y implied volatility)  

## 6	Contributors
* [Rajesh Rao](https://github.com/Raj9898) (Research Analyst 22’)

