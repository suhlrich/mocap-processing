function [EVAL_TM] = findLargerKAMpeak(EVAL_TM, subjectdir)

BLpercDif = (EVAL_TM.KAMP1_u(1) - EVAL_TM.KAMP2_u(1))/EVAL_TM.KAMP1_u(1) * 100 ;

if BLpercDif >0 ; largerPeak = 1 ; else ; largerPeak = 2 ;end

if max(EVAL_TM.(['KAMP' num2str(largerPeak) 'percRedux_u'])(2:5)) < 5 && abs(BLpercDif)<5 ;
    if largerPeak == 1 ; largerPeak =2 ; else ; largerPeak = 1 ; end
    if max(EVAL_TM.(['KAMP' num2str(largerPeak) 'percRedux_u'])(2:5)) < 5
        warning('this person couldnt reduce either KAM peak, using originally larger KAM peak') ;
        if largerPeak == 1 ; largerPeak =2 ; else ; largerPeak = 1 ; end
    end
end

EVAL_TM.largerKAMpeak = largerPeak ;