function plot_isotopes_assbly_wise_average()

clc;
close all;

pause on % to enable pause function

run('assbly_file_map.m')

isotopes = {'U235', 'U236', 'U238', ...
    'Np237', 'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242', ...
    'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};

%plot_pin_data(s, isotopes, det_map);
mat_file_name = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'iso_data_assbly_all.mat');

ss = extract_data_into_struct(s, det_map, isotopes);
save(mat_file_name, 'ss', '-v7');
load(mat_file_name, 'ss');

[assbly_cases, ~] = size(ss);

for i = 1:assbly_cases
    plot_assbly_norm(ss(i, :), {'U235', 'U238', 'Pu239', 'Pu240', 'Pu241'}, 'average')
    plot_assbly_error(ss(i, :), {'U235', 'U238', 'Pu239', 'Pu240', 'Pu241'}, 'average_error')
    plot_assbly_error(ss(i, :), {'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'}, 'fiss_prod_average_error')
end

for m = 1:numel(s)
    for iso = 1:length(isotopes)
        isotope_name = ss(m, iso).isotope_name;
        plot_title = ['$ASSBLY \ ', s(m).assbly_name, '$'];
        plot_filename = fullfile(ss(m, iso).plotdir, ['assbly_', s(m).assbly_name, '_', isotope_name]);
        
        plot_assbly_iso_dens_vs_burnup(isotope_name, ...
            ss(m, iso).drag_assbly_data_2l, ...
            ss(m, iso).drag_assbly_data_1l, ...
            ss(m, iso).serp_assbly_data, ...
            plot_title, plot_filename)
        plot_assembly_data(isotope_name, ...
            plot_title, plot_filename, ...
            ss(m, iso).drag_assbly_data_1l, ...
            ss(m, iso).drag_assbly_data_2l, ...
            ss(m, iso).serp_assbly_data)
    end
end

end

function [ss] = extract_data_into_struct(s, det_map, isotopes)

for m = 1:numel(s)
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    
    iso_data_2l = load(s(m).drag_burn_mat_filename);
    iso_data_1l = load(s(m).drag_burn_mat_filename_1L);
    
    %% plot assembly-wise density vs burnup
    for iso = 1:length(isotopes)
        isotope_name = isotopes{iso};
        
        fprintf(1, 'ASSBLY-%s %s\n', s(m).assbly_name, isotope_name);
        
        drag_assbly_data_2l = get_drag_assbly_iso_dens( ...
            isotope_name, s(m).mix_map, ...
            iso_data_2l.isotopes_mix, iso_data_2l.isotopes_dens, iso_data_2l.isotopes_used, iso_data_2l.volume_mix, ...
            bu_steps);
        
        drag_assbly_data_1l = get_drag_assbly_iso_dens( ...
            isotope_name, s(m).mix_map, ...
            iso_data_1l.isotopes_mix, iso_data_1l.isotopes_dens, iso_data_1l.isotopes_used, iso_data_1l.volume_mix, ...
            bu_steps);
        
        serp_assbly_data = get_serp_assbly_iso_dens( ...
            isotope_name, det_map, s(m).mix_map, s(m).serp_dep_filename);
        
        burnup_serp = serp_assbly_data.burnup';
        burnup_drag_1l = drag_assbly_data_1l.burnup;
        burnup_drag_2l = drag_assbly_data_2l.burnup;
        
        [~, pos_d] = intersect(burnup_drag_1l, burnup_serp);
        [~, pos_s] = intersect(burnup_serp, burnup_drag_1l);
        
        assert(all(burnup_serp(pos_s) == burnup_drag_1l(pos_d)) == 1)
        assert(all(burnup_serp(pos_s) == burnup_drag_2l(pos_d)) == 1)
        
        drag_assbly_data_1l.burnup = drag_assbly_data_1l.burnup(pos_d);
        drag_assbly_data_1l.iso_dens_ave = drag_assbly_data_1l.iso_dens_ave(pos_d);
        drag_assbly_data_2l.burnup = drag_assbly_data_2l.burnup(pos_d);
        drag_assbly_data_2l.iso_dens_ave = drag_assbly_data_2l.iso_dens_ave(pos_d);
        serp_assbly_data.burnup = serp_assbly_data.burnup(pos_s);
        serp_assbly_data.iso_dens_ave = serp_assbly_data.iso_dens_ave(pos_s);
        
        ss(m, iso).assbly_name = ['assbly_', s(m).assbly_name];
        ss(m, iso).isotope_name = isotope_name;
        ss(m, iso).drag_assbly_data_2l = drag_assbly_data_2l;
        ss(m, iso).drag_assbly_data_1l = drag_assbly_data_1l;
        ss(m, iso).serp_assbly_data = serp_assbly_data;
        ss(m, iso).plotdir = plotdir;
    end
end

end

function plot_assbly_norm(data, isotopes, name)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', data(1).plotdir);
set(figure1, 'PaperPositionMode', 'auto');
set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

%% normalized data

h1 = subplot(2, 1, 1);
hold(h1, 'on');
yh1 = ylabel({'$Normalized \ atomic \ density$'; '$~~~~~~~~~~~n / max(n)$'}, ...
    'Interpreter', 'latex');
p1 = get(yh1, 'position');

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};

[~, c] = size(data);

for j = 1:c
    
    if ~any(strcmp(isotopes, data(j).isotope_name))
        continue
    end
    
    bu(j, :) = data(j).serp_assbly_data.burnup';
    drag_1L(j, :) = data(j).drag_assbly_data_1l.iso_dens_ave;
    drag_2L(j, :) = data(j).drag_assbly_data_2l.iso_dens_ave;
    serp(j, :) = data(j).serp_assbly_data.iso_dens_ave;
    h = plot(bu(j, :), drag_1L(j, :)./max(drag_1L(j, :)), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'LineWidth', 1.0, 'LineStyle', ':', ...
        'DisplayName', [data(j).isotope_name, ' 1L D5']);
    
    colors{j} = get(h, 'Color');
    
    plot(bu(j, :), drag_2L(j, :)./max(drag_2L(j, :)), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'LineWidth', 1.0, 'LineStyle', '--', ...
        'DisplayName', [data(j).isotope_name, ' 2L D5'], ...
        'Color', colors{j})
    
    plot(bu(j, :), serp(j, :)./max(serp(j, :)), ...
        'LineWidth', 1.0, 'LineStyle', '-', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data(j).isotope_name, ' S2'], ...
        'Color', colors{j})
end

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 4);

%% relative error
pause(1);

h2 = subplot(2, 1, 2);

hold(h2, 'on');

ymin = 0;
ymax = 0;

for j = 1:c
    
    if ~any(strcmp(isotopes, data(j).isotope_name))
        continue
    end
    
    rel_error_1L(j, :) = (100 * (1. - drag_1L(j, :) ./ serp(j, :)));
    rel_error_2L(j, :) = (100 * (1. - drag_2L(j, :) ./ serp(j, :)));
    h = plot(bu(j, :), rel_error_1L(j, :), ...
        'LineWidth', 1.0, 'LineStyle', ':', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data(j).isotope_name, ' 1L'], ...
        'Color', colors{j});
    
    plot(bu(j, :), rel_error_2L(j, :), ...
        'LineWidth', 1.0, 'LineStyle', '-', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data(j).isotope_name, ' 2L'], ...
        'Color', colors{j})
    
    if min([rel_error_1L(j, 7:end), rel_error_2L(j, 7:end)]) < ymin
        ymin = min([rel_error_1L(j, 7:end), rel_error_2L(j, 7:end)]);
    end
    
    if max([rel_error_1L(j, 7:end), rel_error_2L(j, 7:end)]) > ymax
        ymax = max([rel_error_1L(j, 7:end), rel_error_2L(j, 7:end)]);
    end
end

set(gca, 'Ylim', [round(ymin-0.6), round(ymax+0.6)]);

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel({'$~~~~~Relative \ error$'; '$100 \times (S2 - D5)/S2 \ \%$'}, ...
    'Interpreter', 'latex');
p2 = get(yh2, 'position');
lh2 = legend(h2, 'show', 'Location', 'NorthEastOutside');
set(lh2, 'FontSize', 4);
grid(h2, 'on');

pause(1);

h2.Position(3) = h1.Position(3);
lh2.Position(1) = lh1.Position(1);
lh2.Position(3) = lh1.Position(3);

pause(1);

print(figure1, fullfile(data(j).plotdir, [data(j).assbly_name, '_', name, '.eps']), '-depsc');
close(figure1)

end

function plot_assbly_error(data, isotopes, name)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', [data(1).plotdir, ' ave error']);
set(figure1, 'PaperPositionMode', 'auto');
set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

%% normalized data

h1 = subplot(1, 1, 1);
hold(h1, 'on');
xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh1 = ylabel({'$~~~~~Relative \ error$'; '$100 \times (S2 - D5)/S2 \ \%$'}, ...
    'Interpreter', 'latex');

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};

[~, c] = size(data);

%% relative error

ymin = 0;
ymax = 0;

for j = 1:c
    if ~any(strcmp(isotopes, data(j).isotope_name))
        continue
    end
    
    if any(strcmp({'U235', 'U236', 'U238'}, data(j).isotope_name))
        cut = 1;
    elseif any(strcmp({'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'}, data(j).isotope_name))
        cut = 10;
    else
        cut = 7;
    end
    
    bu(j, :) = data(j).serp_assbly_data.burnup';
    drag_1L(j, :) = data(j).drag_assbly_data_1l.iso_dens_ave;
    drag_2L(j, :) = data(j).drag_assbly_data_2l.iso_dens_ave;
    serp(j, :) = data(j).serp_assbly_data.iso_dens_ave;
    
    rel_error_1L(j, :) = (100 * (1. - drag_1L(j, :) ./ serp(j, :)));
    rel_error_2L(j, :) = (100 * (1. - drag_2L(j, :) ./ serp(j, :)));
    
    h = plot(bu(j, cut:end), rel_error_1L(j, cut:end), ...
        'LineWidth', 1.1, 'LineStyle', '--', ...
        'DisplayName', [data(j).isotope_name, ' 1L']);
    
    colors{j} = get(h, 'Color');
    
    plot(bu(j, cut:end), rel_error_2L(j, cut:end), ...
        'LineWidth', 1.1, 'LineStyle', '-', ...
        'DisplayName', [data(j).isotope_name, ' 2L'], ...
        'Color', colors{j})
    
    if min([rel_error_1L(j, cut:end), rel_error_2L(j, cut:end)]) < ymin
        ymin = min([rel_error_1L(j, cut:end), rel_error_2L(j, cut:end)]);
    end
    
    if max([rel_error_1L(j, cut:end), rel_error_2L(j, cut:end)]) > ymax
        ymax = max([rel_error_1L(j, cut:end), rel_error_2L(j, cut:end)]);
    end
end

set(gca, 'Ylim', [round(ymin-0.6), round(ymax+0.6)]);

lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 4);
grid(h1, 'on');

print(figure1, fullfile(data(j).plotdir, [data(j).assbly_name, '_', name, '.eps']), '-depsc');
close(figure1)

end

function plot_pin_data(s, isotopes, det_map)

for m = 1:4
    
    %% plot burnup vs keff
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    
    %% plot iso densities inside specific pins
    
    iso_data_2l = load(s(m).drag_burn_mat_filename);
    iso_data_1l = load(s(m).drag_burn_mat_filename_1L);
    
    for j = 1:length(s(m).pin_names)
        for k = 1:length(isotopes)
            
            pin_name = s(m).pin_names{j};
            isotope_name = isotopes{k};
            
            drag_pin_data_2l = get_drag_pin_iso_dens( ...
                pin_name, isotope_name, s(m).mix_map, ...
                iso_data_2l.isotopes_mix, iso_data_2l.isotopes_dens, ...
                iso_data_2l.isotopes_used, iso_data_2l.volume_mix, ...
                bu_steps);
            
            drag_pin_data_1l = get_drag_pin_iso_dens( ...
                pin_name, isotope_name, s(m).mix_map, ...
                iso_data_1l.isotopes_mix, iso_data_1l.isotopes_dens, ...
                iso_data_1l.isotopes_used, iso_data_1l.volume_mix, ...
                bu_steps);
            
            serp_pin_data = get_serp_pin_iso_dens( ...
                pin_name, isotope_name, det_map, s(m).mix_map, s(m).serp_dep_filename);
            
            plot_title = ['$ASSBLY \ ', s(m).assbly_name, '\ ', pin_name, '\ 1L \ 2L$'];
            plot_filename = fullfile(plotdir, ['assbly_', s(m).assbly_name, '_pin_', pin_name, '_', isotope_name, '_1l_2l_full']);
            plot_pin_iso_dens_vs_burnup_1l_2l_full(isotopes{k}, plot_title, plot_filename, ...
                drag_pin_data_2l, drag_pin_data_1l, serp_pin_data)
        end
    end
end

end

function plot_assbly_iso_dens_vs_burnup( ...
    isotope_name, drag_assbly_data_2l, drag_assbly_data_1l, serp_assbly_data, ...
    plot_title, plot_filename)
%plot_assbly_iso_dens_vs_burnup Plot assbly-wise average iso density vs burnup

figure1 = figure('Name', plot_title);

axes1 = axes('Parent', figure1);
grid(axes1, 'on');
hold(axes1, 'on');

xlabel('$Burnup \ GWd/tU$', 'Interpreter', 'latex');
title(plot_title, 'Interpreter', 'latex');
ylabel('$Atomic \ density \ 10^{24}/cc$', 'Interpreter', 'latex');

plot(serp_assbly_data.burnup, serp_assbly_data.iso_dens_ave, ...
    'DisplayName', [isotope_name, ' S2'], ...
    'LineWidth', 1.5, 'LineStyle', '-', 'Marker', 'none');
plot(drag_assbly_data_2l.burnup, drag_assbly_data_2l.iso_dens_ave, ...
    'DisplayName', [isotope_name, ' D5 2L'], ...
    'LineWidth', 1.5, 'LineStyle', '-', 'Marker', 'none');
plot(drag_assbly_data_1l.burnup, drag_assbly_data_1l.iso_dens_ave, ...
    'DisplayName', [isotope_name, ' D5 1L'], ...
    'LineWidth', 1.5, 'LineStyle', '-', 'Marker', 'none');

legend1 = legend(axes1, 'show');
set(legend1, 'FontSize', 7);
print(gcf, [plot_filename, '_density.eps'], '-depsc');
close(figure1);

figure2 = figure('Name', 'Relative Error');
grid('on');
hold('on');

xlabel('$Burnup \ GWd/tU$', 'Interpreter', 'latex');
ylabel({'$Relative \ Error$'; '$100 \times \frac{S2 - D5}{S2} \%$'}, 'Interpreter', 'latex');

burnup_serp = serp_assbly_data.burnup';
burnup_drag_2l = drag_assbly_data_2l.burnup;
burnup_drag_1l = drag_assbly_data_1l.burnup;

% assert arrays are equal
assert(all(burnup_drag_1l == burnup_drag_2l) == 1)

[~, pos_d] = intersect(burnup_drag_2l, burnup_serp);
[~, pos_s] = intersect(burnup_serp, burnup_drag_2l);

burnup = burnup_serp(pos_s);
rel_error_2l = (100 * (1 - drag_assbly_data_2l.iso_dens_ave(pos_d) ./ serp_assbly_data.iso_dens_ave(pos_s)));
rel_error_1l = (100 * (1 - drag_assbly_data_1l.iso_dens_ave(pos_d) ./ serp_assbly_data.iso_dens_ave(pos_s)));

plot(burnup(5:end), rel_error_2l(5:end), ...
    'Marker', 'o', 'MarkerSize', 5, ...
    'LineWidth', 1.0, 'LineStyle', '-', ...
    'DisplayName', [isotope_name, ' 2L PIN'])
plot(burnup(5:end), rel_error_1l(5:end), ...
    'Marker', '+', 'MarkerSize', 5, ...
    'LineWidth', 1.0, 'LineStyle', '-', ...
    'DisplayName', [isotope_name, ' 1L PIN'])

hold('off');
lh4 = legend('show');
set(lh4, 'FontSize', 7);
print(gcf, [plot_filename, '_error.eps'], '-depsc');
close(figure2);
end

function plot_assembly_data( ...
    isotope_name, plot_title, plot_filename, ...
    drag_assbly_data_1l, drag_assbly_data_2l, serp_assbly_data)

burnup_serp = serp_assbly_data.burnup';
burnup_drag_1l = drag_assbly_data_1l.burnup;
burnup_drag_2l = drag_assbly_data_2l.burnup;

[~, pos_d] = intersect(burnup_drag_1l, burnup_serp);
[~, pos_s] = intersect(burnup_serp, burnup_drag_1l);

assert(all(burnup_serp(pos_s) == burnup_drag_1l(pos_d)) == 1)
assert(all(burnup_serp(pos_s) == burnup_drag_2l(pos_d)) == 1)

bu = burnup_serp;

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_title);
set(figure1, 'PaperPositionMode', 'auto');

axes1 = axes('Parent', figure1);

%% comparison of isotopic density

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

ylabel({'$Atomic \ density$'; '$~~~~~10^{24}/cm^{3}$'}, 'Interpreter', 'latex');


drag_1l = drag_assbly_data_1l.iso_dens_ave(pos_d);
drag_2l = drag_assbly_data_2l.iso_dens_ave(pos_d);

serp = serp_assbly_data.iso_dens_ave(pos_s);
rel_error_1l = (100 * (1 - drag_1l ./ serp));
rel_error_2l = (100 * (1 - drag_2l ./ serp));

h = plot(bu, drag_1l, ...
    'Marker', 'none', 'LineWidth', 1.2, 'LineStyle', ':', ...
    'DisplayName', '1L D5');


plot(bu, drag_2l, ...
    'Marker', 'none', 'LineWidth', 1.2, 'LineStyle', '--', ...
    'DisplayName', '2L D5');

plot(bu, serp, ...
    'Marker', 'none', 'LineWidth', 1.0, 'LineStyle', '-', ...
    'DisplayName', 'S2')


set(h1, 'xticklabel', [])

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 5);

%% relative error
pause(1);

h2 = subplot(2, 1, 2);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
ylabel({'$Relative \ error$'; '$100 \times \frac{S2 - D5}{S2} \%$'}, 'Interpreter', 'latex');

ymin = min([rel_error_1l(7:end), rel_error_2l(7:end)]);

plot(bu, rel_error_1l, ...
    'LineWidth', 1.2, 'LineStyle', '-', ...
    'DisplayName', '1L')

plot(bu, rel_error_2l, ...
    'LineWidth', 1.2, 'LineStyle', '-', ...
    'DisplayName', '2L')

if min([rel_error_1l(7:end), rel_error_2l(7:end)]) < ymin
    ymin = min([rel_error_1l(7:end), rel_error_2l(7:end)]);
end

ymax = max([rel_error_1l, rel_error_2l]);
if ymin + sign(ymin) < ymax + 0.5
    set(h2, 'Ylim', [ymin + sign(ymin), ymax + 0.5]);
end

lh2 = legend(h2, 'show', 'Location', 'NorthEastOutside');
set(lh2, 'FontSize', 5);

set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

pause(1);

lh2.Position(1) = lh1.Position(1);
lh2.Position(3) = lh1.Position(3);
h2.Position(3) = h1.Position(3);

pause(1);

print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function plot_pin_iso_dens_vs_burnup_1l_2l_full( ...
    isotope_name, plot_title, plot_filename, ...
    drag_pin_data_2l, drag_pin_data_1l, serp_pin_data)
%plot_pin_iso_dens_vs_burnup_1l_2l_full Plot pin iso densities vs burnup for serpent
% and 1L/2L dragon data

assert(length(drag_pin_data_2l) == length(serp_pin_data))
assert(length(drag_pin_data_1l) == length(serp_pin_data))

burnup_serp = serp_pin_data(1).burnup;
burnup_drag_2l = drag_pin_data_2l(1).burnup;
burnup_drag_1l = drag_pin_data_1l(1).burnup;

% assert arrays are equal
assert(all(burnup_drag_1l == burnup_drag_2l) == 1)

[~, pos_d] = intersect(burnup_drag_2l, burnup_serp);
[~, pos_s] = intersect(burnup_serp, burnup_drag_2l);

burnup_serp = burnup_serp(pos_s);
burnup_drag_2l = burnup_drag_2l(pos_d);
burnup_drag_1l = burnup_drag_1l(pos_d);

figure1 = figure('Name', plot_title);
set(figure1, 'Position', [0, 0, 1920, 1080])
set(figure1, 'PaperPositionMode', 'auto');

%% comparison of isotopic density in each ring of the pin

h1 = subplot(2, 2, 1);
grid(h1, 'on');
hold(h1, 'on');

xlabel('$Burnup \ MWd/tU$', 'Interpreter', 'latex');
ylabel('$Atomic \ density \ 10^{24}/cc$', 'Interpreter', 'latex');

colors = cell(length(drag_pin_data_2l)-1, 1);

for i = 1:length(drag_pin_data_2l) - 1
    h = plot(burnup_drag_2l, drag_pin_data_2l(i).iso_dens(pos_d), ...
        'Marker', 'none', 'LineWidth', 1.3, 'LineStyle', '-', ...
        'DisplayName', [isotope_name, ' D5 2L ', num2str(drag_pin_data_2l(i).mix_number), ...
        ' ', drag_pin_data_2l(i).ring_letter]);
    
    colors{i} = get(h, 'Color');
    
    plot(burnup_drag_1l, drag_pin_data_1l(i).iso_dens(pos_d), ...
        'Marker', 'none', 'LineWidth', 1.3, 'LineStyle', '--', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' D5 1L ', num2str(drag_pin_data_1l(i).mix_number), ...
        ' ', drag_pin_data_1l(i).ring_letter]);
    
    plot(burnup_serp, serp_pin_data(i).iso_dens(pos_s), ...
        'Marker', 'none', 'LineWidth', 1.5, 'LineStyle', ':', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' S2 ', num2str(drag_pin_data_2l(i).mix_number), ...
        ' ', drag_pin_data_2l(i).ring_letter])
    
end

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'best');
set(lh1, 'FontSize', 7);

%% relative error

h2 = subplot(2, 2, 3);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ MWd/tU$', 'Interpreter', 'latex');
ylabel({'$Relative \ Error$'; '$100 \times \frac{S2 - D5}{S2} \%$'}, 'Interpreter', 'latex');

for i = 1:length(drag_pin_data_2l) - 1
    
    rel_error_2l = (100 * (1 - drag_pin_data_2l(i).iso_dens(pos_d) ./ serp_pin_data(i).iso_dens(pos_s)));
    rel_error_1l = (100 * (1 - drag_pin_data_1l(i).iso_dens(pos_d) ./ serp_pin_data(i).iso_dens(pos_s)));
    
    plot(burnup_serp(5:end), rel_error_2l(5:end), ...
        'Marker', 'o', 'MarkerSize', 5, ...
        'LineWidth', 1.2, 'LineStyle', '-', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' 2L ', num2str(drag_pin_data_2l(i).mix_number), ...
        ' ', drag_pin_data_2l(i).ring_letter])
    plot(burnup_serp(5:end), rel_error_1l(5:end), ...
        'Marker', '+', 'MarkerSize', 5, ...
        'LineWidth', 1.2, 'LineStyle', '--', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' 1L ', num2str(drag_pin_data_2l(i).mix_number), ...
        ' ', drag_pin_data_2l(i).ring_letter])
end

lh2 = legend(h2, 'show');
set(lh2, 'FontSize', 7);

%% pin-wise isotopic density

h3 = subplot(2, 2, 2);
grid(h3, 'on');
hold(h3, 'on');

xlabel('$Burnup \ MWd/tU$', 'Interpreter', 'latex');
ylabel('$Atomic \ density \ 10^{24}/cc$', 'Interpreter', 'latex');

pin_idx = numel(drag_pin_data_2l);

% plot pin wise densities
plot(drag_pin_data_2l(pin_idx).burnup, drag_pin_data_2l(pin_idx).iso_dens, ...
    'Marker', 'none', ...
    'LineWidth', 1.5, 'LineStyle', '-', ...
    'DisplayName', [isotope_name, ' D5 2L PIN'])

plot(drag_pin_data_1l(pin_idx).burnup, drag_pin_data_1l(pin_idx).iso_dens, ...
    'Marker', 'none', ...
    'LineWidth', 1.5, 'LineStyle', '--', ...
    'DisplayName', [isotope_name, ' D5 1L PIN'])

plot(serp_pin_data(pin_idx).burnup, serp_pin_data(pin_idx).iso_dens, ...
    'Marker', 'none', ...
    'LineWidth', 1.5, 'LineStyle', ':', ...
    'DisplayName', [isotope_name, ' S2 PIN'])

hold(h3, 'off');
lh3 = legend(h3, 'show');
set(lh3, 'FontSize', 7);

%% pin-wise iso density relative error

h4 = subplot(2, 2, 4);
grid(h4, 'on');
hold(h4, 'on');

xlabel('$Burnup \ MWd/tU$', 'Interpreter', 'latex');
ylabel({'$Relative \ Error$'; '$100 \times \frac{S2 - D5}{S2} \%$'}, 'Interpreter', 'latex');

rel_error_2l = (100 * (1 - drag_pin_data_2l(pin_idx).iso_dens(pos_d) ./ serp_pin_data(pin_idx).iso_dens(pos_s)));
rel_error_1l = (100 * (1 - drag_pin_data_1l(pin_idx).iso_dens(pos_d) ./ serp_pin_data(pin_idx).iso_dens(pos_s)));

plot(burnup_serp(5:end), rel_error_2l(5:end), ...
    'Marker', 'o', 'MarkerSize', 5, ...
    'LineWidth', 1.0, 'LineStyle', '-', ...
    'DisplayName', [isotope_name, ' 2L PIN'])
plot(burnup_serp(5:end), rel_error_1l(5:end), ...
    'Marker', '+', 'MarkerSize', 5, ...
    'LineWidth', 1.0, 'LineStyle', '-', ...
    'DisplayName', [isotope_name, ' 1L PIN'])

hold(h4, 'off');
lh4 = legend(h4, 'show');
set(lh4, 'FontSize', 7);

%% adjust and save the plot

a = axes;
t1 = title({plot_title; ''}, 'Interpreter', 'latex');
set(a, 'Visible', 'off');
set(t1, 'Visible', 'on');

set(gcf, 'Units', 'inches');
screenposition = get(gcf, 'Position');
set(gcf, 'PaperPosition', [0, 0, screenposition(3:4)], 'PaperSize', screenposition(3:4));
print(gcf, [plot_filename, '.pdf'], '-dpdf');

close(figure1)

end