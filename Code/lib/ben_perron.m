%
% Author, Rajesh Rao
% 
% Test for structural breaks in linear models as detailed in the Bai and 
% Perron (1998, 2003 a,b) paper
% ------------------------------------------------------------------------
%
%
%
%

function ben_perron(y, X)
    
     % check the variable type entered 
    assert(isa(y, 'double'), ...
        'TypeError: independent variable must be of type double');
    assert(isa(X, 'double'), ...
        'TypeError: dependent variable must be of type double');
    
    % check the dimensionality and case of function parameters
    assert(size(y, 1) == size(X, 1), ...
        'both variables must have the same number of observations'); 
    
    % compute stationary variables
    [T, ~] = size(X);
    maxBreaks = T * ( T + 1 ) / 2;
    
    % compute the OLS residuals from regression
    [~,~,residuals] = regress(y, X); 
    squaredResiduals = residuals .^ 2;
     
    
end
