function plot_isotopes_pin_bench_norm()
%plot_isotopes_pin_bench_norm
% Plot normalized iso density
% for actinides and fission products of 3 pin benchmarks

pause on % to enable pause function

run('pins_file_map.m');

d(1).isotopes = { ...
    'U235', 'U236', 'U238', 'Np237', ...
    'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242'};
d(1).name = 'actinides';

d(2).isotopes = {'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};
d(2).name = 'fission_products';

for i = 1:numel(s)
    plotdir = fileparts(s(i).drag_burn_mat_filename);
    for j = 1:numel(d)
        [data] = get_pin_data(s(i), det_map, d(j).isotopes);
        plot_norm(data(1, :), fullfile(plotdir, ['pin_', s(i).pin_name, '_', d(j).name]))
    end
end

end

function plot_norm(data, plot_filename)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_filename);
set(figure1, 'PaperPositionMode', 'auto');
set(figure1, 'PaperPositionMode', 'auto');
set(figure1, 'Position', [680, 550, 640, 420]);

h1 = subplot(2, 1, 1);
hold(h1, 'on');
yh1 = ylabel({'$Normalized \ atomic \ density$'; '$~~~~~~~~~~~n / max(n)$'}, ...
    'Interpreter', 'latex');
p1 = get(yh1, 'position');

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};

[~, c] = size(data);

for j = 1:c
    bu = data{j}.burnup;
    drag = data{j}.drag_iso_dens_pin_ave;
    serp = data{j}.serp_iso_dens_pin_ave;
    
    h = plot(bu, drag./max(drag), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 3, ...
        'LineWidth', 1.0, 'LineStyle', '-', ...
        'DisplayName', [data{j}.isotope_name, ' D5']);
    
    colors{j} = get(h, 'Color');
    
    plot(bu, serp./max(serp), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 3, ...
        'LineWidth', 1.0, 'LineStyle', '--', ...
        'DisplayName', [data{j}.isotope_name, ' S2'], ...
        'Color', colors{j})
end

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 5);

%% relative error
pause(1)

h2 = subplot(2, 1, 2);

hold(h2, 'on');
grid(h2, 'on');

ymin = 0;
ymax = 0;

for j = 1:c
    bu = data{j}.burnup;
    drag = data{j}.drag_iso_dens_pin_ave;
    serp = data{j}.serp_iso_dens_pin_ave;
    rel_error = (100 * (1. - drag ./ serp));
    
    plot(bu, rel_error, ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 3, ...
        'LineWidth', 1.2, 'LineStyle', '-', ...
        'DisplayName', [data{j}.isotope_name], ...
        'Color', colors{j})
    
    if min(rel_error(7:end)) < ymin
        ymin = min(rel_error(7:end));
    end
    if max(rel_error(7:end)) > ymax
        ymax = max(rel_error(7:end));
    end
end

limsy = get(gca, 'YLim');
set(gca, 'Ylim', [round(ymin-0.5), round(ymax+0.5)]);

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel({'$~~~~~Relative \ error$'; '$100 \times (S2 - D5)/S2 \ \%$'}, ...
    'Interpreter', 'latex');
p2 = get(yh2, 'position');
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

% print(figure1,[plot_filename '.pdf'],'-dpdf','-r0');
% print(figure1,[plot_filename '.png'],'-dpng','-r300');
print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function [data] = get_pin_data(s, det_map, isotopes)

data = cell(numel(s), length(isotopes));

for m = 1:numel(s)
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
        
        burnup_serp = serp_pin_data(5).burnup;
        burnup_drag = drag_pin_data_1l(5).burnup;
        
        [~, pos_d] = intersect(burnup_drag, burnup_serp);
        [~, pos_s] = intersect(burnup_serp, burnup_drag);
        
        assert(all(burnup_serp(pos_s) == burnup_drag(pos_d)) == 1)
        
        d.isotope_name = isotope_name;
        d.burnup = burnup_serp(pos_s);
        d.drag_iso_dens_pin_ave = drag_pin_data_1l(5).iso_dens(pos_d);
        d.serp_iso_dens_pin_ave = serp_pin_data(5).iso_dens(pos_s);
        d.pin_name = drag_pin_data_1l(5).pin_name;
        d.serp_out_path = s(m).serp_out_path;
        d.drag_out_path = s(m).drag_out_path;
        data{m, k} = d;
    end
end

end
