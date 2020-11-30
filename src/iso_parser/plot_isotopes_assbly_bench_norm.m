function plot_isotopes_assbly_bench_norm()
%plot_isotopes_assbly_bench_norm Plot normalized iso density for assbly benchmarks

pause on % to enable pause function

run('assbly_file_map.m');

d(1).isotopes = {'U235', 'U236', 'U238', 'Np237', 'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242'};
d(1).name = 'uranium_actinides';

d(2).isotopes = {'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};
d(2).name = 'fission_products';

d(3).isotopes = {'U235', 'U236', 'U238'};
d(3).name = 'uranium';


for i = 1:numel(s)
    for j = 1:length(s(i).pin_names)
        for k = 1:numel(d)
            plotdir = fileparts(s(i).drag_burn_mat_filename);
            pin_name = s(i).pin_names{j};
            [data] = get_assbly_data(s(i), det_map, pin_name, d(k).isotopes);
            plot_filename = fullfile(plotdir, ['assbly_', s(i).assbly_name, '_pin_', pin_name, '_', d(k).name]);
            plot_title = ['assbly_', s(i).assbly_name, '_pin_', pin_name, '_', d(k).name];
            plot_norm(data, plot_filename, plot_title)
        end
    end
end

end

function plot_norm(data, plot_filename, plot_title)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_title);
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
    bu = data{j}.burnup;
    drag_1L = data{j}.drag_iso_dens_pin_ave_1L;
    drag_2L = data{j}.drag_iso_dens_pin_ave_2L;
    serp = data{j}.serp_iso_dens_pin_ave;
    h = plot(bu, drag_1L./max(drag_1L), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'LineWidth', 1.0, 'LineStyle', ':', ...
        'DisplayName', [data{j}.isotope_name, ' 1L D5']);
    
    colors{j} = get(h, 'Color');
    
    plot(bu, drag_2L./max(drag_2L), ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'LineWidth', 1.0, 'LineStyle', '--', ...
        'DisplayName', [data{j}.isotope_name, ' 2L D5'], ...
        'Color', colors{j})
    
    plot(bu, serp./max(serp), ...
        'LineWidth', 1.0, 'LineStyle', '-', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data{j}.isotope_name, ' S2'], ...
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
    bu = data{j}.burnup;
    drag_1L = data{j}.drag_iso_dens_pin_ave_1L;
    drag_2L = data{j}.drag_iso_dens_pin_ave_2L;
    serp = data{j}.serp_iso_dens_pin_ave;
    rel_error_1L = (100 * (1. - drag_1L ./ serp));
    rel_error_2L = (100 * (1. - drag_2L ./ serp));
    h = plot(bu, rel_error_1L, ...
        'LineWidth', 1.0, 'LineStyle', ':', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data{j}.isotope_name, ' 1L'], ...
        'Color', colors{j});
    
    plot(bu, rel_error_2L, ...
        'LineWidth', 1.0, 'LineStyle', '-', ...
        'Marker', all_marks{mod(j, 13)}, 'MarkerSize', 2, ...
        'DisplayName', [data{j}.isotope_name, ' 2L'], ...
        'Color', colors{j})
    
    if min([rel_error_1L(7:end), rel_error_2L(7:end)]) < ymin
        ymin = min([rel_error_1L(7:end), rel_error_2L(7:end)]);
    end
    
    if max([rel_error_1L(7:end), rel_error_2L(7:end)]) > ymax
        ymax = max([rel_error_1L(7:end), rel_error_2L(7:end)]);
    end
end

set(gca, 'Ylim', [round(ymin-0.5), round(ymax+0.5)]);

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel({'$~~~~~Relative \ error$'; '$100 \times (S2 - D5)/S2 \ \%$'}, ...
    'Interpreter', 'latex');
p2 = get(yh2, 'position');
lh2 = legend(h2, 'show', 'Location', 'NorthEastOutside');
set(lh2, 'FontSize', 4);
grid(h2, 'on');

pause(1); % pause to avoid wrong positioning

h2.Position(3) = h1.Position(3);
lh2.Position(1) = lh1.Position(1);
lh2.Position(3) = lh1.Position(3);

pause(1);

%print(figure1,[plot_filename '.pdf'],'-dpdf','-r0')
print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function [data] = get_assbly_data(s, det_map, pin_name, isotopes)

data = cell(numel(s), length(isotopes));

for m = 1:numel(s)
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    iso_data_2l = load(s(m).drag_burn_mat_filename);
    iso_data_1l = load(s(m).drag_burn_mat_filename_1L);
    
    for k = 1:length(isotopes)
        
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
        
        burnup_serp = serp_pin_data(5).burnup;
        burnup_drag = drag_pin_data_1l(5).burnup;
        
        [~, pos_d] = intersect(burnup_drag, burnup_serp);
        [~, pos_s] = intersect(burnup_serp, burnup_drag);
        
        assert(all(burnup_serp(pos_s) == burnup_drag(pos_d)) == 1)
        
        d.isotope_name = isotope_name;
        d.burnup = burnup_serp(pos_s);
        d.drag_iso_dens_pin_ave_1L = drag_pin_data_1l(5).iso_dens(pos_d);
        d.drag_iso_dens_pin_ave_2L = drag_pin_data_2l(5).iso_dens(pos_d);
        d.serp_iso_dens_pin_ave = serp_pin_data(5).iso_dens(pos_s);
        d.pin_name = drag_pin_data_1l(5).pin_name;
        d.serp_out_path = s(m).serp_out_path;
        d.drag_out_path_2L = s(m).drag_out_path;
        d.drag_out_path_1L = s(m).drag_out_path_1L;
        data{m, k} = d;
    end
end

end
