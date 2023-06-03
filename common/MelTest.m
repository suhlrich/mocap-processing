for i = 1:length(badStepInd)
    Matrix(badStepInd(i)) = [];
end
for i = 1:size(Matrix,2)
    plot(Matrix(i).rCOPx)
    hold on
end
