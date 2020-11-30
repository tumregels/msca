function plot_isotopes_assbly_bench_rings()

pause on % to enable pause function

run('assbly_file_map.m');

isotopes = {'U235', 'Pu239', 'Pu240', 'Pu241'};

for m = 1:numel(s)
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    
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
            
            plot_title = ['$ASSBLY \ ', s(m).assbly_name, '\ ', pin_name, '$'];
            plot_filename = [plotdir, '/assbly_', s(m).assbly_name, '_pin_', pin_name, '_', isotope_name];
            plot_data(isotopes{k}, ...
                plot_title, plot_filename, ...
                drag_pin_data_1l, drag_pin_data_2l, serp_pin_data)
            
        end
    end
end

end


function plot_data( ...
    isotope_name, plot_title, plot_filename, ...
    drag_pin_data_1l, drag_pin_data_2l, serp_pin_data)

assert(length(drag_pin_data_1l) == length(serp_pin_data))
assert(length(drag_pin_data_2l) == length(serp_pin_data))

burnup_serp = serp_pin_data(1).burnup;
burnup_drag_1l = drag_pin_data_1l(1).burnup;
burnup_drag_2l = drag_pin_data_2l(1).burnup;

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

%% comparison of isotopic density in each ring of the pin

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

ylabel({'$Atomic \ density$'; '$~~~~~10^{24}/cm^{3}$'}, 'Interpreter', 'latex');

for i = 1:length(drag_pin_data_2l) - 1
    drag_1l = drag_pin_data_1l(i).iso_dens(pos_d);
    drag_2l = drag_pin_data_2l(i).iso_dens(pos_d);
    ring_1l = drag_pin_data_1l(i).ring_letter;
    ring_2l = drag_pin_data_2l(i).ring_letter;
    serp = serp_pin_data(i).iso_dens(pos_s);
    rel_error_1l{i} = (100 * (1 - drag_1l ./ serp));
    rel_error_2l{i} = (100 * (1 - drag_2l ./ serp));
    
    h = plot(bu, drag_1l, ...
        'Marker', 'none', 'LineWidth', 1.1, 'LineStyle', ':', ...
        'DisplayName', [isotope_name, ' ', ring_1l, ' 1L D5']);
    
    colors{i} = get(h, 'Color');
    
    plot(bu, drag_2l, ...
        'Marker', 'none', 'LineWidth', 1.1, 'LineStyle', '--', ...
        'Color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', ring_2l, ' 2L D5']);
    
    plot(bu, serp, ...
        'Marker', 'none', 'LineWidth', 1.1, 'LineStyle', '-', ...
        'Color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', ring_2l, ' S2'])
    
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

ymin = min([rel_error_1l{1}(7:end), rel_error_2l{1}(7:end)]);

for i = 1:length(drag_pin_data_2l) - 1
    
    ring = drag_pin_data_2l(i).ring_letter;
    %'Marker','o','MarkerSize',4,...
    %'Marker','+','MarkerSize',4,...
    plot(burnup_serp, rel_error_1l{i}, ...
        'LineWidth', 1.1, 'LineStyle', ':', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', ring, ' 1L'])
    
    plot(burnup_serp, rel_error_2l{i}, ...
        'LineWidth', 1.1, 'LineStyle', '-', ...
        'color', colors{i}, ...
        'DisplayName', [isotope_name, ' ', ring, ' 2L'])
    
    if min([rel_error_1l{i}(7:end), rel_error_2l{i}(7:end)]) < ymin
        ymin = min([rel_error_1l{i}(7:end), rel_error_2l{i}(7:end)]);
    end
end

ymax = max([cell2mat(rel_error_1l), cell2mat(rel_error_2l)]);
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