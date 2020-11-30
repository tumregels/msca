function plot_isotopes_pin_bench_rings()

pause on % to enable pause function

run('pins_file_map.m');

isotopes = {'U235', 'U238', 'Pu239', 'Pu240', 'Pu241'};

for m = 1:numel(s)
    
    %% plot burnup vs keff
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    
    iso_data_1l = load(s(m).drag_burn_mat_filename);
    
    for k = 1:length(isotopes)
        
        pin_name = s(m).pin_name;
        isotope_name = isotopes{k};
        
        drag_pin_data_1l = get_drag_pin_iso_dens( ...
            pin_name, isotope_name, s(m).mix_map, ...
            iso_data_1l.isotopes_mix, iso_data_1l.isotopes_dens, ...
            iso_data_1l.isotopes_used, iso_data_1l.volume_mix, ...
            bu_steps);
        
        serp_pin_data = get_serp_pin_iso_dens( ...
            pin_name, isotope_name, det_map, s(m).mix_map, s(m).serp_dep_filename);
        
        plot_title = ['$PIN \ ', pin_name, '$'];
        plot_filename = fullfile(plotdir, ['pin_', s(m).pin_name, '_', isotope_name]);
        plot_data(isotopes{k}, ...
            plot_title, plot_filename, drag_pin_data_1l, serp_pin_data)
        
    end
    
end

end


function plot_data( ...
    isotope_name, plot_title, plot_filename, drag_pin_data, serp_pin_data)
%plot_pin_iso_dens_vs_burnup_adjusted Plot pin iso densities vs burnup for serpent
% and dragon with relative error

assert(length(drag_pin_data) == length(serp_pin_data))

burnup_serp = serp_pin_data(1).burnup;
burnup_drag = drag_pin_data(1).burnup;

[~, pos_d] = intersect(burnup_drag, burnup_serp);
[~, pos_s] = intersect(burnup_serp, burnup_drag);

burnup_serp = burnup_serp(pos_s);
burnup_drag = burnup_drag(pos_d);

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_title);
set(figure1, 'PaperPositionMode', 'auto');
set(figure1, 'Position', [680, 550, 640, 420]);
axes1 = axes('Parent', figure1);

%% comparison of isotopic density in each ring of the pin

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

if strcmp(isotope_name, 'U238')
    ylabel({'$Atomic~density,~10^{24}/cm^{3}$'}, 'Interpreter', 'latex');
else
    ylabel({'$Atomic \ density$'; '$~~~~~10^{24}/cm^{3}$'}, 'Interpreter', 'latex');
end

colors = cell(length(drag_pin_data)-1, 1);

for i = 1:length(drag_pin_data) - 1
    h = plot(burnup_drag, drag_pin_data(i).iso_dens(pos_d), ...
        'Marker', 'none', 'LineWidth', 1.1, 'LineStyle', '-', ...
        'DisplayName', [isotope_name, ' ', drag_pin_data(i).ring_letter, ' D5']);
    
    colors{i} = get(h, 'Color');
    
    plot(burnup_serp, serp_pin_data(i).iso_dens(pos_s), ...
        'Marker', 'none', 'LineWidth', 1.1, 'LineStyle', '--', ...
        'Color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', drag_pin_data(i).ring_letter, ' S2'])
    
end

set(h1, 'xticklabel', [])

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 5);

%% relative error for each ring in the pin
pause(1);

h2 = subplot(2, 1, 2);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
ylabel({'$Relative \ error$'; '$100 \times \frac{S2 - D5}{S2} \%$'}, 'Interpreter', 'latex');

ymin = 0;
ymax = 0;

for i = 1:length(drag_pin_data) - 1
    rel_error = (100 * (1 - drag_pin_data(i).iso_dens(pos_d) ./ serp_pin_data(i).iso_dens(pos_s)));
    plot(burnup_serp, rel_error, ...
        'Marker', 'o', 'MarkerSize', 3, ...
        'LineWidth', 1.2, 'LineStyle', '-', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', drag_pin_data(i).ring_letter])
    
    if min(rel_error(7:end)) < ymin
        ymin = min(rel_error(7:end));
    end
    if max(rel_error(7:end)) > ymax
        ymax = max(rel_error(7:end));
    end
end

set(h2, 'Ylim', [round(ymin-0.6), round(ymax+0.6)]);

lh2 = legend(h2, 'show', 'Location', 'NorthEastOutside');
set(lh2, 'FontSize', 5);

pause(1);

h2.Position(3) = h1.Position(3);
lh2.Position(1) = lh1.Position(1);
lh2.Position(3) = lh1.Position(3);

pause(1);

set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end