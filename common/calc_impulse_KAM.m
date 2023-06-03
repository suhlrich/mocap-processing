function impulse = calc_impulse(KAM, time_change)

% len = length(KAM) - 1;
% impulse = 0;
% for i = 1:len
%     impulse = (KAM(i+1) - KAM(i)) * time_change;
% end

% 
% y = KAM;
% num_vals = length(KAM);
% max_x = time_chanage * num_vals;
% x = linspace(0, max_x, num_vals);

impulse = time_change * trapz(KAM);
%(Or impulse = trapz(time_change, KAM) -- same thing

end
