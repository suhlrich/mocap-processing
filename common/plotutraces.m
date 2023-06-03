function plotutraces(u,sd,traces)

if size(traces,2) == 101 ;
    traces = traces' ;
end
close(figure(1223))
figure(1223)
x = 0:100 ;
fill([x,fliplr(x)],[u-sd fliplr(u+sd)],0.7*ones(1,3),'Linestyle','none')
hold on
plot(x,u,'k','Linewidth',2)
plot(traces)
xlim([0,100])