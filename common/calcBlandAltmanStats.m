function BAstats = calcBlandAltmanStats(vals_true,vals_pred) ;

if size(vals_true,2) < size(vals_true,1) % if column vector
    vals_true = vals_true' ;
    vals_pred = vals_pred' ;
end

dVals = vals_pred - vals_true ;
n = length(dVals) ;
t = tinv(.975,n-1) ;

sd = std(dVals) ;
BAstats.bias = mean(dVals) ;
BAstats.LOA = BAstats.bias + 1.96*sd * [-1,1] ;

se_bias = sqrt(sd^2/n) ;
confidence_bias = se_bias * t ;

se_LOA = sqrt(3*sd^2/n) ;
confidence_LOA = se_LOA * t ;


BAstats.bias95CI = BAstats.bias + confidence_bias * [-1, 1] ;
BAstats.LOA95CI = repmat(BAstats.LOA,2,1) + confidence_LOA * [-1, -1;1,1] ;

BAstats.xAxis = mean([vals_true; vals_pred]) ;
BAstats.yAxis = dVals ;