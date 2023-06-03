function Shull = loadShullPain()

ShullPain = load(['W:\OA_GaitRetraining\Literature\Shull\Shull2013PainNumbers.mat']) ; 
ShullPain = ShullPain.Shull2013PainNumbers ;

Shull.NRS.Medial.Wk2_u = table2array(ShullPain(1,{'Wk1_u'}))/10 ;
Shull.NRS.Medial.Wk7_u = table2array(ShullPain(1,{'Wk6_u'}))/10;
Shull.NRS.Medial.Wk11_u = table2array(ShullPain(1,{'Wk10_u'}))/10;

Shull.KOOS.womacPain.Wk2_u = table2array(ShullPain(2,{'Wk1_u'}));
Shull.KOOS.womacPain.Wk7_u = table2array(ShullPain(2,{'Wk6_u'}));
Shull.KOOS.womacPain.Wk11_u = table2array(ShullPain(2,{'Wk10_u'}));

Shull.KOOS.womacFxn.Wk2_u = table2array(ShullPain(3,{'Wk1_u'}));
Shull.KOOS.womacFxn.Wk7_u= table2array(ShullPain(3,{'Wk6_u'}));
Shull.KOOS.womacFxn.Wk11_u = table2array(ShullPain(3,{'Wk10_u'}));

Shull.NRS.Medial.Wk2_sd = table2array(ShullPain(1,{'Wk1_sd'}))/10;
Shull.NRS.Medial.Wk7_sd = table2array(ShullPain(1,{'Wk6_sd'}))/10;
Shull.NRS.Medial.Wk11_sd = table2array(ShullPain(1,{'Wk10_sd'}))/10;

Shull.KOOS.womacPain.Wk2_sd = table2array(ShullPain(2,{'Wk1_sd'}));
Shull.KOOS.womacPain.Wk7_sd = table2array(ShullPain(2,{'Wk6_sd'}));
Shull.KOOS.womacPain.Wk11_sd = table2array(ShullPain(2,{'Wk10_sd'}));

Shull.KOOS.womacFxn.Wk2_sd = table2array(ShullPain(3,{'Wk1_sd'}));
Shull.KOOS.womacFxn.Wk7_sd= table2array(ShullPain(3,{'Wk6_sd'}));
Shull.KOOS.womacFxn.Wk11_sd = table2array(ShullPain(3,{'Wk10_sd'}));

Shull.NRS.Medial.Delta.Wk7_u = Shull.NRS.Medial.Wk2_u - Shull.NRS.Medial.Wk7_u;
Shull.NRS.Medial.Delta.Wk11_u = Shull.NRS.Medial.Wk2_u - Shull.NRS.Medial.Wk11_u;

Shull.KOOS.womacPain.Delta.Wk7_u = Shull.KOOS.womacPain.Wk2_u - Shull.KOOS.womacPain.Wk7_u;
Shull.KOOS.womacPain.Delta.Wk11_u = Shull.KOOS.womacPain.Wk2_u - Shull.KOOS.womacPain.Wk11_u;

Shull.KOOS.womacFxn.Delta.Wk7_u = Shull.KOOS.womacFxn.Wk2_u - Shull.KOOS.womacFxn.Wk7_u;
Shull.KOOS.womacFxn.Delta.Wk11_u = Shull.KOOS.womacFxn.Wk2_u - Shull.KOOS.womacFxn.Wk11_u;
