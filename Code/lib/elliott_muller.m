% 
% Author, Rajesh Rao
% 
% We consider tests of the null hypothesis of a stable linear model
% yt = Xt'β + εt against the alternative of a partially unstable 
% model yt = Xt'βt + εt, where variation in βt is of the strong form. 
% Further details refer to the Elliott and Muller (2006) paper
% ------------------------------------------------------------------------
%
% Input:
%   :param: y (type array) - vector
%       The output vector, dependent variable
%   :param: X (type array) - matrix/vector  
%       The dataset you look to regress on, independent variable  
%   :param: errorType (type char) - text word
%       A string identifier for the epsilon being correlated or 
%       uncorrelated to the independent variable 
% 
% Output:
%   :param: QLL (type double) - floating point number
%       The test statistic 
% 
% Syntax:
%   QLL = elliott_muller(y, X, errorType)
% 
% Description:
%   QLL = elliott_muller(y, X, errorType) returns the quasi local level
%   created by Elliot and Muller for testing the stability of the beta
%   coefficients in linear regression models
% 
% Examples:
%   
%   X = [1.5 ; 1.2; 2.3; 3.4; 2.9; 3.8; 1.7; 2.5];
%   y = [3.7 ; 3.5; 4.7; 5.9; 4.9; 5.2; 3.9; 4.2];
%    
%   elliott_muller(y, X, 'correlated')
% 
%   ans =
%       -11.9511
% 
%   Given the low number we can safely reject the null-hypothesis (for 
%   details on asymptoric critical values, refer to paper)
% 
%   ----------------------------------------------------------------------
% 
%   X = [1; 2; 3; 4; 5];
%   y = [5.2825; 6.5379; 7.4942; 8.7531; 9.9728];
% 
%   elliott_muller(y, X, 'uncorrelated')
% 
%   ans =
%       -6.7487
% 
%   Since the number is not low enough to regect the null-hypothesis, we
%   keep it (for details on asymptoric critical values, refer to paper)
% 
%   ----------------------------------------------------------------------
% 
%   X = [[1, 7]; [2, 8]; [3, 9]];
%   y = [-5.4016; -5.7779; -3.7985];
% 
%   elliott_muller(y, X, 'uncorrelated')
% 
%   ans =
%       -0.00
% 
%   

function QLL = elliott_muller(y, X, errorType)
    
    % check the variable type entered 
    assert(isa(y, 'double'), ...
        'TypeError: independent variable must be of type double');
    assert(isa(X, 'double'), ...
        'TypeError: dependent variable must be of type double');
    assert(isa(errorType, 'char'), ...
        'TypeError: error type specified for epislon must be type char');
    
    % check the dimensionality and case of function parameters
    assert(size(y, 1) == size(X, 1), ...
        'both variables must have the same number of observations'); 
    assert(strcmp(errorType, 'correlated') | ...
           strcmp(errorType, 'uncorrelated'), ...
        'error type included, correlated and uncorrelated'); 
    
    
    % compute the OLS residuals from regression, from step (1)
    [~,~,res1] = regress(y, X);
    
    % transpose of independent variable 
    xTranspose = X';
    
    % compute stationary variables
    [T, k] = size(X); 
    rBar = 1 - 10 / T;
    epsilonSqr = (res1.^2);
    
    % initialize the Vx estimators
    vX = zeros(k, k);
    
    % compute the Vx estimator, from step (2)
    if strcmpi(errorType, 'correlated')         % consistent est.
        vX = cov(xTranspose.*res1);
        
    elseif strcmpi(errorType, 'uncorrelated')   % heteroscedasticity est.
        for i = 1:T
            % compute relation ∑X{t}X{t}'εt
            vX = vX + ( xTranspose(:, i) * X(i, :) * epsilonSqr(i) );
        end
        vX = vX * (1/T);
    end
    
    % compute a measures Ut, from step (3)
    uHat = (mpower(vX, -0.5) * xTranspose)' .* res1; 
    
    % create new matrix/vector wHat, from step (4)
    wHat = zeros(T, k);                 % pre-allocating memory 
    wHat(1, :) = uHat(1, :);            % initialize first row of wHat
    
    % compute recursive relation w{t} = rw{t-1} + ΔU{t}
    for i = 1:T-1
        uDiff = uHat(i+1, :) - uHat(i, :); 
        wHat(i+1, :) = rBar * wHat(i, :) + uDiff;
    end
    
    % compute rHat array over t-periods
    rVector = 1 - 10 ./ (1:T) ;     
    
    % compute the OLS residuals from regression, from step (5)
    sqrResiduals = zeros(T,1);
    for i = 1:k
        [~,~,res2] = regress(wHat(:, i), rVector');   % regress wHat on R
        sqrResiduals = sqrResiduals + (res2 .^ 2);    % square residuals 
    end
    
    sumResiduals = sum(sqrResiduals);       % sum of squared residuals
    reducedFactor = sum(sum(uHat.^2));      % double sum of squared U
    
    % computes the “quasi local level" test statistic, from step (6)
    QLL = sumResiduals * rBar - reducedFactor;
end