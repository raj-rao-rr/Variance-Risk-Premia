%
% Author, Desi Volker
% 
% Performs OLS regressions with GMM corrected standard errors
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: lhv (type array) - T x N vector
%       Left hand variable data, dependent varaible y
%   :param: rhv (type array) - T x K vector
%       Right hand variable data, independent variable X
%   
%   NOTE: If N > 1, this runs N regressions of the left hand columns on 
%   all the (same) right hand variables. 
%   
%   :param: lags (type int)
%       Number of lags to include in GMM corrected standard errors
%   :param: weight (type int) - restricted to 1, 0, -1
%       1 for newey-west weighting 
%       0 for even weighting
%      -1 skips standard error computations. This speeds the program up a 
%         lot; used inside simulations where only estimates are needed
% 
%   NOTE: you must make the first column of rhv a vector of ones 
%   if you want a constant. 
% 
% Output:
%   :param: bv (type array) - K x N vector
%       Regression coefficients vector of coefficients
%   :param: sebv (type array) - K x N matrix 
%       Standard errors of parameters. (Note this will be negative if 
%       variance comes out negative) 
%   :param: R2v (type double) - N X 1   
%       Unadjusted R2 measure
%   :param: R2vadj (type double) - N X 1 
%       Adjusted R2 measure
%   :param: errv (type array) - T X N vector
%        Returns residuals from lhv-rhv*bv, if specified 
%   :param: v (type double) - N*K X K matrix
%       Variance covariance matrix of estimated parameters. If there are 
%       many y variables, the vcv are stacked vertically
%   :param: F (type array) - N x 3 vector
%       [Chi squared statistic, degrees of freedom, pValue] for all 
%       coeffs jointly zero. Note: program checks whether first is a 
%       constant and ignores that one for test
% 

function [bv,sebv,R2v,R2vadj,errv,v,F] = olsgmm(lhv, rhv, lags, weight)

    % check the dimensionality and case of function parameters
    assert(size(lhv, 1) == size(rhv, 1), ...
    'DimError: Both variables must have the same number of observations.');
    assert(weight == 1 | weight == 0 | weight == -1, ...
    'Error: Weight parameter only accepts the integers, 1, 0, or -1')
    
    % determine the scope of left-hand and right-hand variables
    [T, N] = size(lhv);
    [~, K] = size(rhv);
    
    % initialize memory of variables
    sebv = zeros(K, N);
    F = zeros(N, 3); 
    Exxprim = ((rhv'*rhv) / T);
    bv = rhv\lhv;
    v = zeros(N*K, K); 

    % Checks if user wants standard error computations
    % if user provides -1, we skip computation (improves speed)
    if weight == -1  
        sebv=NaN; R2v=NaN; R2vadj=NaN; errv=NaN; v=NaN; F=NaN;
        
    else 
        errv = lhv-rhv*bv;                  % compute standard residuals
        s2 = mean(errv.^2);
        vary = lhv-ones(T,1)*mean(lhv);     % compute variation
        vary = mean(vary.^2);               % compute sum of squares

        R2v = (1-s2./vary)';                    % compute R-squared
        R2vadj= (1-(s2./vary)*(T-1)/(T-K))';    % compute adj. R-squared

        % compute GMM standard errors
        for indx = 1:N
            err=errv(:,indx);
            inner = (rhv.*(err*ones(1,K)))'*(rhv.*(err*ones(1,K)))/T;
            
            % if lags are provided we compute GMM over window 
            for jindx = (1:lags)
                inneradd = (rhv(1:T-jindx,:).*(err(1:T-jindx)*ones(1,K)))'...
                          *(rhv(1+jindx:T,:).*(err(1+jindx:T)*ones(1,K)))/T;
                inner = inner + (1-weight*jindx/(lags+1))*(inneradd + inneradd');
            end

            % compute variance covariance matrix of estimated parameters
            varb = 1/T * (Exxprim \ inner) / Exxprim;
            
            % check whether first column is all ones (constant measure)
            if rhv(:,1) == ones(T,1) 
                % compute chi-square, degrees of freedom, p-value stats
                chi2val = bv(2:end,indx)'*(varb(2:end,2:end)\bv(2:end,indx));
                dof = size(bv(2:end,1),1); 
                pval = 1-cdf('chi2',chi2val, dof); 

                F(indx,1:3) = [chi2val, dof, pval]; 
            else
                chi2val = bv(:,indx)'*(varb\bv(:,indx));
                dof = size(bv(:,1),1); 
                pval = 1-cdf('chi2',chi2val, dof); 
                
                F(indx,1:3) = [chi2val, dof, pval]; 
            end 
            
            if indx == 1
                % store K x K covariance matrix in first K rows
                v(1:K, :) = varb;
            else
                % every iteration we move rows by a factor of K
                v(K*indx-K+1:K*indx, :) = varb;
            end
            
            % compute standard errors
            seb = diag(varb);
            seb = sign(seb).*(abs(seb).^0.5);
            sebv(:,indx) = seb;
        end
        
    end
    
end     
         