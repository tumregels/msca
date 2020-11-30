function [bu_vs_keff] = get_drag_bu_vs_keff(filename)
%get_drag_bu_vs_keff Parse dragon output for burnup and keff values

filecontent = fileread(filename);
data = regexp(filecontent, ...
    '>\|\+\+\+ Burnup=(?<burnup>.*?)\s+Keff=(?<keff>.*?)\s+(?=\|>\d+)', 'names');

for i = 1:numel(data)
    data(i).keff = str2double(data(i).keff);
    data(i).burnup = str2double(data(i).burnup) / 1000;
end

bu_vs_keff = [data.burnup; data.keff]';

end
