function [bu_vs_keff] = get_serp_bu_vs_keff(filename)
%get_serp_bu_vs_keff Read serpent output and extract burnup and keff values

% load data
run(filename);

bu_vs_keff = [BURNUP(:, 1), ABS_KEFF(:, 1)];

end
