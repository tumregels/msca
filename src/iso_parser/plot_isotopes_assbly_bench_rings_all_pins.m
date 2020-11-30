function plot_isotopes_assbly_bench_rings_all_pins()

pause on % to enable pause function

run('assbly_file_map.m');

isotopes = {'U235', 'U236', 'U238', ...
    'Np237', 'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242', ...
    'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};

mat_file_name = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'iso_data_all_pins.mat');

% extract/save/load data
sss = extract_data_into_struct(s, det_map, isotopes);
save(mat_file_name, 'sss', '-v7');
load(mat_file_name, 'sss');

[mm, ii, ~] = size(sss);
for m = 1:mm % from assembly A to D
    for i = 1:ii
        data = sss(m, i, :);
        plot_data_error(data)
        plot_data_error_gd(data, s(m))
        plot_data_error_uox(data, s(m))
    end
end

end


function [sss] = extract_data_into_struct(s, det_map, isotopes)

for m = 1:numel(s)
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    bu_steps = drag_bu_vs_keff(:, 1);
    
    iso_data_2l = load(s(m).drag_burn_mat_filename);
    iso_data_1l = load(s(m).drag_burn_mat_filename_1L);
    pin_names = fieldnames(s(m).mix_map);
    
    for p = 1:length(pin_names)
        for i = 1:length(isotopes)
            fprintf(1, '%d %d %d\n', m, i, p);
            
            pin_name = pin_names{p};
            isotope_name = isotopes{i};
            
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
            
            burnup_serp = serp_pin_data(1).burnup;
            burnup_drag_1l = drag_pin_data_1l(1).burnup;
            burnup_drag_2l = drag_pin_data_2l(1).burnup;
            
            [~, pos_d] = intersect(burnup_drag_1l, burnup_serp);
            [~, pos_s] = intersect(burnup_serp, burnup_drag_1l);
            
            assert(all(burnup_serp(pos_s) == burnup_drag_1l(pos_d)) == 1)
            assert(all(burnup_serp(pos_s) == burnup_drag_2l(pos_d)) == 1)
            
            assert(length(serp_pin_data) == length(drag_pin_data_1l))
            assert(length(serp_pin_data) == length(drag_pin_data_2l))
            
            for l = 1:length(serp_pin_data)
                drag_pin_data_1l(l).burnup = drag_pin_data_1l(l).burnup(pos_d);
                drag_pin_data_1l(l).iso_dens = drag_pin_data_1l(l).iso_dens(pos_d);
                drag_pin_data_2l(l).burnup = drag_pin_data_2l(l).burnup(pos_d);
                drag_pin_data_2l(l).iso_dens = drag_pin_data_2l(l).iso_dens(pos_d);
                serp_pin_data(l).burnup = serp_pin_data(l).burnup(pos_s);
                serp_pin_data(l).iso_dens = serp_pin_data(l).iso_dens(pos_s);
            end
            
            sss(m, i, p).assbly_name = ['assbly_', s(m).assbly_name];
            sss(m, i, p).pin_name = pin_name;
            sss(m, i, p).isotope_name = isotope_name;
            sss(m, i, p).drag_pin_data_2l = drag_pin_data_2l;
            sss(m, i, p).drag_pin_data_1l = drag_pin_data_1l;
            sss(m, i, p).serp_pin_data = serp_pin_data;
            sss(m, i, p).plotdir = plotdir;
        end
    end
end

end


function plot_data_error(data)

bu = data(1).serp_pin_data(1).burnup;
plot_filename = fullfile(data(1).plotdir, [data(1).assbly_name, '_', data(1).isotope_name, '_all_pins_error']);

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', [data(1).assbly_name, '_', data(1).isotope_name]);
set(figure1, 'PaperPositionMode', 'auto');

axes1 = axes('Parent', figure1);

%% relative error of 2L scheme inside each ring in all pins

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

ylabel({'$Relative~error~2L$'}, 'Interpreter', 'latex');

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
all_styles = {'-.', '-', ':', '--'};

if any(strcmp({'U235', 'U236', 'U238'}, data(1).isotope_name))
    cut = 1;
elseif any(strcmp({'Pu241', 'Pu242', 'Sm150'}, data(1).isotope_name)) && ~strcmp('assbly_A', data(1).assbly_name)
    cut = 10;
elseif strcmp('assbly_A', data(1).assbly_name)
    cut = 6;
else
    cut = 7;
end

bu_less_20 = find(bu <= 20);
bu_less_20 = [bu_less_20(1:10), bu_less_20(11:3:end)]; % reduce to see the markers in the plot
bu_more_20 = find(bu > 20);
ind = [bu_less_20, bu_more_20];
ind = ind(cut:end);

for i = 1:length(data)
    h = plot(nan, nan);
    colors{i} = get(h, 'color');
    delete(h)
    
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        drag_1l = data(i).drag_pin_data_1l(j).iso_dens;
        drag_2l = data(i).drag_pin_data_2l(j).iso_dens;
        serp = data(i).serp_pin_data(j).iso_dens;
        rel_error_1l{i, j} = (100 * (1 - drag_1l ./ serp));
        rel_error_2l{i, j} = (100 * (1 - drag_2l ./ serp));
        ring = data(i).drag_pin_data_2l(j).ring_letter;
        h(i, j) = plot(bu(ind), rel_error_2l{i, j}(ind), ...
            'LineWidth', 1.0, 'LineStyle', all_styles{mod(i, 4)+1}, ...
            'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
            'Color', colors{i}, ...
            'DisplayName', data(i).pin_name);
        if j ~= 1
            set(get(get(h(i, j), 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
        end
    end
end

set(h1, 'xticklabel', [])

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 6);

%% relative error of 1L scheme inside each ring in all pins

h2 = subplot(2, 1, 2);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
ylabel({'$Relative~error~1L$'}, 'Interpreter', 'latex');

for i = 1:length(data)
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        ring = data(i).drag_pin_data_1l(j).ring_letter;
        plot(bu(ind), rel_error_1l{i, j}(ind), ...
            'LineWidth', 1.0, 'LineStyle', all_styles{mod(i, 4)+1}, ...
            'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
            'color', colors{i})
    end
end

%% average relative error

set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

%lh2.Position(1) = lh1.Position(1);
%lh2.Position(3) = lh1.Position(3);
pause(1);
h2.Position(3) = h1.Position(3);

%print(figure1, [plot_filename, '.eps'], '-depsc');
print(figure1, [plot_filename, '.pdf'], '-dpdf', '-r0');

close(figure1)

end


function plot_data_error_gd(data, s)

bu = data(1).serp_pin_data(1).burnup;
plot_filename = fullfile(data(1).plotdir, [data(1).assbly_name, '_', data(1).isotope_name, '_all_pins_error']);

if strcmp(s.assbly_name, 'A')
    return
end

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', [data(1).assbly_name, '_', data(1).isotope_name]);
set(figure1, 'PaperPositionMode', 'auto');

axes1 = axes('Parent', figure1);

%% relative error of 2L scheme inside each ring in the gd-pins

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

%ylabel({'$Relative~error~2L$'},'Interpreter','latex');

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
all_styles = {'-.', '-', ':', '--'};

if any(strcmp({'U235', 'U236', 'U238'}, data(1).isotope_name))
    cut = 1;
elseif any(strcmp({'Pu241', 'Pu242', 'Sm150'}, data(1).isotope_name)) && ~strcmp('assbly_A', data(1).assbly_name)
    cut = 10;
elseif strcmp('assbly_A', data(1).assbly_name)
    cut = 6;
else
    cut = 7;
end

bu_less_20 = find(bu <= 20);
bu_less_20 = [bu_less_20(1:10), bu_less_20(11:3:end)]; % reduce to see the markers in the plot
bu_more_20 = find(bu > 20);
ind = [bu_less_20, bu_more_20];
ind = ind(cut:end);

for i = 1:length(data)
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        drag_1l = data(i).drag_pin_data_1l(j).iso_dens;
        drag_2l = data(i).drag_pin_data_2l(j).iso_dens;
        serp = data(i).serp_pin_data(j).iso_dens;
        rel_error_1l{i, j} = (100 * (1 - drag_1l ./ serp));
        rel_error_2l{i, j} = (100 * (1 - drag_2l ./ serp));
        ring = data(i).drag_pin_data_2l(j).ring_letter;
        % plot only Gd pins
        if any(strcmp(s.gd_pins, data(i).pin_name))
            h(i, j) = plot(bu(ind), rel_error_2l{i, j}(ind), ...
                'LineWidth', 1.1, 'LineStyle', all_styles{mod(i, 4)+1}, ...
                'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
                'DisplayName', [data(i).pin_name, ' ', ring]);
            colors{j} = get(h(i, j), 'color');
        end
    end
end

set(h1, 'xticklabel', [])

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 6);

%% relative error of 1L scheme inside each ring in the gd-pins

h2 = subplot(2, 1, 2);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
%ylabel({'$Relative~error~1L$'},'Interpreter','latex');

for i = 1:length(data)
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        ring = data(i).drag_pin_data_1l(j).ring_letter;
        if any(strcmp(s.gd_pins, data(i).pin_name))
            plot(bu(ind), rel_error_1l{i, j}(ind), ...
                'LineWidth', 1.1, 'LineStyle', all_styles{mod(i, 4)+1}, ...
                'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
                'color', colors{j})
        end
    end
end

%% average relative error

set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

%lh2.Position(1) = lh1.Position(1);
%lh2.Position(3) = lh1.Position(3);
pause(1);
h2.Position(3) = h1.Position(3);

%print(figure1, [plot_filename, '_gd.eps'], '-depsc');
print(figure1, [plot_filename, '_gd.pdf'], '-dpdf', '-r0');
close(figure1)

end


function plot_data_error_uox(data, s)

bu = data(1).serp_pin_data(1).burnup;
plot_filename = fullfile(data(1).plotdir, [data(1).assbly_name, '_', data(1).isotope_name, '_all_pins_error']);

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', [data(1).assbly_name, '_', data(1).isotope_name]);
set(figure1, 'PaperPositionMode', 'auto');

axes1 = axes('Parent', figure1);

%% relative error of 2L scheme inside each ring in the uox-pins

h1 = subplot(2, 1, 1);
grid(h1, 'on');
hold(h1, 'on');

if ~strcmp(s.assbly_name, 'E')
    ylabel({'$Relative~error~2L$'}, 'Interpreter', 'latex');
end

all_marks = {'o', '+', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
all_styles = {'-.', '-', ':', '--'};

if any(strcmp({'U235', 'U236', 'U238'}, data(1).isotope_name))
    cut = 1;
elseif any(strcmp({'Pu241', 'Pu242', 'Sm150'}, data(1).isotope_name)) && ~strcmp('assbly_A', data(1).assbly_name)
    cut = 10;
elseif strcmp('assbly_A', data(1).assbly_name)
    cut = 6;
else
    cut = 7;
end

bu_less_20 = find(bu <= 20);
bu_less_20 = [bu_less_20(1:10), bu_less_20(11:3:end)]; % reduce to see the markers in the plot
bu_more_20 = find(bu > 20);
ind = [bu_less_20, bu_more_20];
ind = ind(cut:end);

for i = 1:length(data)
    h = plot(nan, nan);
    colors{i} = get(h, 'color');
    delete(h)
    
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        drag_1l = data(i).drag_pin_data_1l(j).iso_dens;
        drag_2l = data(i).drag_pin_data_2l(j).iso_dens;
        serp = data(i).serp_pin_data(j).iso_dens;
        rel_error_1l{i, j} = (100 * (1 - drag_1l ./ serp));
        rel_error_2l{i, j} = (100 * (1 - drag_2l ./ serp));
        ring = data(i).drag_pin_data_2l(j).ring_letter;
        % plot only UOX pins
        if ~any(strcmp(s.gd_pins, data(i).pin_name))
            h(i, j) = plot(bu(ind), rel_error_2l{i, j}(ind), ...
                'LineWidth', 1.0, 'LineStyle', all_styles{mod(i, 4)+1}, ...
                'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
                'Color', colors{i}, ...
                'DisplayName', data(i).pin_name);
            if j ~= 1
                set(get(get(h(i, j), 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
            end
        end
    end
end

set(h1, 'xticklabel', [])

hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEastOutside');
set(lh1, 'FontSize', 6);

%% relative error of 1L scheme inside each ring in the uox-pins

h2 = subplot(2, 1, 2);
grid(h2, 'on');
hold(h2, 'on');

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');

if ~strcmp(s.assbly_name, 'E')
    ylabel({'$Relative~error~1L$'}, 'Interpreter', 'latex');
end

for i = 1:length(data)
    for j = 1:length(data(i).drag_pin_data_1l) - 1
        if ~any(strcmp(s.gd_pins, data(i).pin_name))
            plot(bu(ind), rel_error_1l{i, j}(ind), ...
                'LineWidth', 1.0, 'LineStyle', all_styles{mod(i, 4)+1}, ...
                'Marker', all_marks{mod(i, 13)+1}, 'MarkerSize', 3, ...
                'color', colors{i})
        end
    end
end

%% average relative error

set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

pause(1);
h2.Position(3) = h1.Position(3);

%print(figure1, [plot_filename, '_uox.eps'], '-depsc');
print(figure1, [plot_filename, '_uox.pdf'], '-dpdf', '-r0');
close(figure1)

end