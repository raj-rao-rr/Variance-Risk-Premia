% Author, Rajesh Rao
% 
% Tests for instability or breaks in coefficients in regression models 
% detailed in the Elliott and Muller (2006) paper
% ------------------------------------------------------------------------
% We consider tests of the null hypothesis of a stable linear model
% yt = Xtβ + Ztδ + εt against the alternative of a partially unstable 
% model yt = Xtβt + Ztδ + εt, where variation in βt is of the strong form
%
%   :param: y (type array) - vector
%       The output vector, dependent variable
%   :param: X (type array) - matrix/vector  
%       The dataset you look to regress on, independent variable  
%   :param: errorType (type char) - text word
%       A string identifier for the epsilon being correlated or 
%       uncorrelated to the independent variable 
% 
% Syntax:
%   QLL = elliott_muller(y, X, errorType)
% 
% Description:
%   QLL = elliott_muller(y, X, errorType) returns the quasi Local Level
%   created by Elliot and Muller for testing the stability of the beta
%   coefficients in linear regression models
% 
% Examples:
%   1-D dimentionsla vector, independent variable
%   X = [1.5 ; 1.2; 2.3; 3.4; 2.9; 3.8; 1.7; 2.5];
%   y = [3.7 ; 3.5; 4.7; 5.9; 4.9; 5.2; 3.9; 4.2];
%   
%   Uncorrelated residuals (epsilon) example 
%   elliott_muller(y, X, 'uncorrelated')
% 
%   ans =
%       -243.8223
% 
%   Correlated residuals (epsilon) example 
%   elliott_muller(y, X, 'correlated')
% 
%   ans =
%       -238.6144
% 

function QLL = elliott_muller(y, X, errorType)

    % compute the OLS res1 from regression, from step (1)
    [~,~,res1] = regress(y, X);
    
    % compute stationary variables
    [T, k] = size(X); 
    rBar = 1-10/T;
    
    % compute the Vx estimator, from step (2)
    if strcmpi(errorType, 'correlated')
        % consistent estimator, vX is a scaler
        vX = cov(X.*res1);
    elseif strcmpi(errorType, 'uncorrelated')
        %  heteroscedasticity robust estimator, vX is a vector
        vX = (1/T) * (X*X'*res1.^2);
    end
    
    % compute a measures Ut, from step (3)
    uHat = sqrt(vX).*X.*res1; 
    
    % create new matrix/vector wHat, from step (4)
    wHat = zeros(T-1, k);       % pre-allocating memory 
    wHat(1, :) = uHat(1, :);    % initialize first row of wHat
    
    for i = 1:T-1
        uDiff = uHat(i+1, :) - uHat(i, :); 
        % computes each row via itterative recursion 
        wHat(i+1, :) = rBar * uHat(1, :) + uDiff;
    end
    
    % compute rHat array over t-periods
    rVector = (1:T) * rBar;
    
    % compute the OLS res1 from regression, from step (5)
    [~,~,res2] = regress(rVector', wHat);
    
    squaredResiduals = res2.^2;
    ssResiduals = sum(squaredResiduals);    % sum of squared residuals
    reducedFactor = sum(sum(uHat.^2));      % double sum of squared U
    
    % computes the “quasi Local Level" test
    QLL = rBar .* ssResiduals - reducedFactor;
end