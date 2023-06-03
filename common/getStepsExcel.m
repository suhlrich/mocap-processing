function stepsOut = getStepsExcel(fileName)
   
warning off
inData = readtable(fileName) ;
stepsOut = inData.TotalSteps ;