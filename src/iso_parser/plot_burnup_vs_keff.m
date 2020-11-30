function plot_burnup_vs_keff()
%plot_burnup_vs_keff Plot burnup vs keff values for all benchmarks

plot_pin_benchmarks();
plot_assbly_benchmarks();

end

function plot_assbly_benchmarks()

run('assbly_file_map.m');

list = cell(numel(s), 1);

for m = 1:numel(s)
    
    %% plot burnup vs keff
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff_2L = get_drag_bu_vs_keff(s(m).drag_result_filename);
    drag_bu_vs_keff_1L = get_drag_bu_vs_keff(s(m).drag_result_filename_1L);
    serp_bu_vs_keff = get_serp_bu_vs_keff(s(m).serp_res_filename);
    plot_title = ['$ASSBLY \ ', s(m).assbly_name, '$'];
    plot_filename = fullfile(plotdir, ['assbly_', s(m).assbly_name, '_burnup_vs_keff']);
    data = plot_assbly_data(drag_bu_vs_keff_2L, drag_bu_vs_keff_1L, ...
        serp_bu_vs_keff, plot_title, plot_filename);
    plot_filename = fullfile(plotdir, ['assbly_', s(m).assbly_name, '_burnup_vs_keff_cut']);
    plot_assbly_data(drag_bu_vs_keff_2L, drag_bu_vs_keff_1L, ...
        serp_bu_vs_keff, plot_title, plot_filename, 25);
    data.name = ['ASSBLY-', s(m).assbly_name];
    list{m} = data;
    
end

data = [list{:}];
mat_file_name = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'data', 'data.mat');
save(mat_file_name, 'data', 'plotdir', '-v7')
load(mat_file_name, 'data', 'plotdir')

plot_filename = fullfile(plotdir, 'assblies_burnup_vs_keff');
plot_assblies(data, plot_filename);

plot_filename = fullfile(plotdir, 'assblies_burnup_vs_keff_partial');
burnup_cut = 25; % GWd/t
plot_assblies(data, plot_filename, burnup_cut);

end

function plot_pin_benchmarks()

run('pins_file_map.m');

list = cell(numel(s), 1);

for m = 1:numel(s)
    
    %% plot burnup vs keff
    
    plotdir = fileparts(s(m).drag_burn_mat_filename);
    drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
    serp_bu_vs_keff = get_serp_bu_vs_keff(s(m).serp_res_filename);
    plot_title = ['$PIN \ ', s(m).pin_name, '$'];
    plot_filename = fullfile(plotdir, ['pin_', s(m).pin_name, '_burnup_vs_keff']);
    data = plot_pin_data(drag_bu_vs_keff, serp_bu_vs_keff, plot_title, plot_filename);
    data.name = ['PIN-', s(m).pin_name];
    list{m} = data;
    
end

data = [list{:}];
plot_filename = fullfile(plotdir, 'pins_burnup_vs_keff');
plot_pins(data, plot_filename)

end

function [data] = plot_pin_data(burnup_vs_keff_drag, burnup_vs_keff_serp, ...
    plot_title, plot_filename)

[~, pos_d] = intersect(burnup_vs_keff_drag(:, 1), burnup_vs_keff_serp(:, 1));
[~, pos_s] = intersect(burnup_vs_keff_serp(:, 1), burnup_vs_keff_drag(:, 1));

burnup_vs_keff_serp = burnup_vs_keff_serp(pos_s, :);
burnup_vs_keff_drag = burnup_vs_keff_drag(pos_d, :);

assert(all(burnup_vs_keff_serp(:, 1) == burnup_vs_keff_drag(:, 1)) == 1)

bu = burnup_vs_keff_serp(:, 1);
keff_serp = burnup_vs_keff_serp(:, 2);
keff_drag = burnup_vs_keff_drag(:, 2);

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_title);
set(figure1, 'PaperPositionMode', 'auto');

%% plot dragon keff

h1 = subplot(2, 1, 1);
hold(h1, 'on');

plot(bu, keff_drag, ...
    'Marker', '+', 'MarkerSize', 4, ...
    'LineWidth', 1.2, 'LineStyle', 'None', ...
    'DisplayName', 'D5', ...
    'Color', 'blue');

plot(bu, keff_serp, ...
    'Marker', 'o', 'MarkerSize', 6, ...
    'LineWidth', 1.2, 'LineStyle', 'None', ...
    'DisplayName', 'S2', ...
    'Color', 'red')

yh1 = ylabel(h1, '$k_{eff}$', 'Interpreter', 'latex', 'FontSize', 13);
p1 = get(yh1, 'position');

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEast');
set(lh1, 'FontSize', 7);

%% relative error

h2 = subplot(2, 1, 2);

disc = (1 ./ keff_serp - 1 ./ keff_drag) * 10^5;

data = struct;
data.bu = bu;
data.disc = disc;
data.keff_drag = keff_drag;
data.keff_serp = keff_serp;

plot(bu, disc, ...
    'Marker', 'o', 'MarkerSize', 3, ...
    'LineWidth', 1.2, 'LineStyle', '-', ...
    'Color', 'blue')

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel(h2, '$Discrepancy \ \Delta a \ pcm$', 'Interpreter', 'latex');
p2 = get(yh2, 'position');

% adjust ylabel position
p1(1) = p2(1);
set(yh1, 'position', p1);

grid(h2, 'on');
set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
%print(figure1, [plot_filename, '.pdf'], '-dpdf', '-r0')
print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function plot_pins(data, plot_filename)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', 'All pins');
set(figure1, 'PaperPositionMode', 'auto');

%% plot dragon keff

h1 = subplot(2, 1, 1);
hold(h1, 'on');

for i = 1:numel(data)
    h = plot(data(i).bu, data(i).keff_drag, ...
        'Marker', '+', 'MarkerSize', 4, ...
        'LineWidth', 1.2, 'LineStyle', 'None', ...
        'DisplayName', ['D5 ', data(i).name]);
    
    colors{i} = get(h, 'Color');
    
    plot(data(i).bu, data(i).keff_serp, ...
        'Marker', 'o', 'MarkerSize', 6, ...
        'LineWidth', 1.2, 'LineStyle', 'None', ...
        'DisplayName', ['S2 ', data(i).name], ...
        'Color', colors{i})
end

yh1 = ylabel(h1, '$k_{eff}$', 'Interpreter', 'latex', 'FontSize', 13);
p1 = get(yh1, 'position');

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEast');
set(lh1, 'FontSize', 7);

%% relative error

h2 = subplot(2, 1, 2);
hold(h2, 'on');

for i = 1:numel(data)
    plot(data(i).bu, data(i).disc, ...
        'Marker', 'o', 'MarkerSize', 3, ...
        'LineWidth', 1.2, 'LineStyle', '-', ...
        'DisplayName', data(i).name, ...
        'Color', colors{i})
end

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel(h2, '$Discrepancy \ \Delta a \ pcm$', 'Interpreter', 'latex');
p2 = get(yh2, 'position');

% adjust ylabel position
p1(1) = p2(1);
set(yh1, 'position', p1);
lh2 = legend(h2, 'show', 'Location', 'East');
set(lh2, 'FontSize', 7);

grid(h2, 'on');
hold(h2, 'off');
set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
%print(figure1,[plot_filename '.pdf'],'-dpdf','-r0')
%print(figure1,[plot_filename '.png'],'-dpng','-r300');
print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function plot_assblies(data, plot_filename, burnup_cut)

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', 'All assblies');
set(figure1, 'Units', 'Inches');

if exist('burnup_cut', 'var')
    for i = 1:numel(data)
        data(i).bu = data(i).bu(data(i).bu <= burnup_cut);
        data(i).disc_1L = data(i).disc_1L(data(i).bu <= burnup_cut);
        data(i).disc_2L = data(i).disc_2L(data(i).bu <= burnup_cut);
        data(i).keff_drag_1L = data(i).keff_drag_1L(data(i).bu <= burnup_cut);
        data(i).keff_drag_2L = data(i).keff_drag_2L(data(i).bu <= burnup_cut);
        data(i).keff_serp = data(i).keff_serp(data(i).bu <= burnup_cut);
    end
end

%% plot dragon keff

h1 = subplot(2, 1, 1);
hold(h1, 'on');

C = [0.3467, 0.5360, 0.6907; ...
    0.9153, 0.2816, 0.2878; ...
    0.4416, 0.7490, 0.4322; ...
    1.0000, 0.5984, 0.2000];

for i = 1:numel(data)
    h = plot(data(i).bu, data(i).keff_drag_1L, ...
        'Marker', '+', 'MarkerSize', 4, ...
        'LineWidth', 1.1, 'LineStyle', 'None', ...
        'DisplayName', ['D5 1L ', data(i).name], ...
        'Color', C(i, :));
    
    plot(data(i).bu, data(i).keff_drag_2L, ...
        'Marker', 'x', 'MarkerSize', 4, ...
        'LineWidth', 1.1, 'LineStyle', 'None', ...
        'DisplayName', ['D5 2L ', data(i).name], ...
        'Color', C(i, :))
    
    plot(data(i).bu, data(i).keff_serp, ...
        'Marker', 'o', 'MarkerSize', 6, ...
        'LineWidth', 1.1, 'LineStyle', 'None', ...
        'DisplayName', ['S2      ', data(i).name], ...
        'Color', C(i, :))
end

yh1 = ylabel(h1, '$k_{eff}$', 'Interpreter', 'latex', 'FontSize', 13);
p1 = get(yh1, 'position');

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'northeastoutside');
set(lh1, 'FontSize', 6);

%% relative error

h2 = subplot(2, 1, 2);
hold(h2, 'on');

for i = 1:numel(data)
    plot(data(i).bu, data(i).disc_2L, ...
        'Marker', 'o', 'MarkerSize', 4, ...
        'LineWidth', 1.1, 'LineStyle', 'None', ...
        'DisplayName', ['2L ', data(i).name, '    '], ...
        'Color', C(i, :))
    
    plot(data(i).bu, data(i).disc_1L, ...
        'Marker', '+', 'MarkerSize', 4, ...
        'LineWidth', 1.1, 'LineStyle', 'None', ...
        'DisplayName', ['1L ', data(i).name, '    '], ...
        'Color', C(i, :))
    
end

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel(h2, '$Discrepancy \ \Delta a \ pcm$', 'Interpreter', 'latex');
p2 = get(yh2, 'position');

% adjust ylabel position
lh2 = legend(h2, 'show', 'Location', 'northeastoutside');
set(lh2, 'FontSize', 6);

grid(h2, 'on');
hold(h2, 'off');

pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])

p1(1) = p2(1);
set(yh1, 'position', p1);

lh2.Position(1) = lh1.Position(1);
lh2.Position(3) = lh1.Position(3);
h2.Position(3) = h1.Position(3);

print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end

function [data] = plot_assbly_data(drag_2L, drag_1L, serp, ...
    plot_title, plot_filename, burnup_cut)

if ~exist('burnup_cut', 'var')
    burnup_cut = 70; % GWd/t
end

[~, pos_d] = intersect(drag_2L(:, 1), serp(:, 1));
[~, pos_s] = intersect(serp(:, 1), drag_2L(:, 1));

serp = serp(pos_s, :);
drag_2L = drag_2L(pos_d, :);
drag_1L = drag_1L(pos_d, :);

assert(all(serp(:, 1) == drag_2L(:, 1)) == 1)
assert(all(serp(:, 1) == drag_1L(:, 1)) == 1)

bu = serp(:, 1);
keff_serp = serp(:, 2);
keff_drag_2L = drag_2L(:, 2);
keff_drag_1L = drag_1L(:, 2);

bu = bu(bu <= burnup_cut);
keff_serp = keff_serp(bu <= burnup_cut);
keff_drag_2L = keff_drag_2L(bu <= burnup_cut);
keff_drag_1L = keff_drag_1L(bu <= burnup_cut);

% tighten the subplots
make_it_tight = true;
subplot = @(m, n, p) subtightplot(m, n, p, [0.05, 0.05], [0.1, 0.05], [0.13, 0.02]);
if ~make_it_tight, clear subplot;
end

figure1 = figure('Name', plot_title);
set(figure1, 'PaperPositionMode', 'auto');

%% plot dragon keff

h1 = subplot(2, 1, 1);
hold(h1, 'on');

plot(bu, keff_drag_2L, ...
    'Marker', '+', 'MarkerSize', 5, ...
    'LineWidth', 1.1, 'LineStyle', 'None', ...
    'DisplayName', 'D5 2L', ...
    'Color', 'blue');

plot(bu, keff_drag_1L, ...
    'Marker', 'x', 'MarkerSize', 5, ...
    'LineWidth', 1.1, 'LineStyle', 'None', ...
    'DisplayName', 'D5 1L', ...
    'Color', 'green');

plot(bu, keff_serp, ...
    'Marker', 'o', 'MarkerSize', 4, ...
    'LineWidth', 1.1, 'LineStyle', 'None', ...
    'DisplayName', 'S2', ...
    'Color', 'red');

yh1 = ylabel(h1, '$k_{eff}$', 'Interpreter', 'latex', 'FontSize', 13);
p1 = get(yh1, 'position');

grid(h1, 'on');
set(h1, 'xticklabel', [])
hold(h1, 'off');
lh1 = legend(h1, 'show', 'Location', 'NorthEast');
set(lh1, 'FontSize', 7);

%% relative error

h2 = subplot(2, 1, 2);
hold(h2, 'on');

disc_1L = (1 ./ keff_serp - 1 ./ keff_drag_1L) * 10^5;
disc_2L = (1 ./ keff_serp - 1 ./ keff_drag_2L) * 10^5;

data = struct;
data.bu = bu;
data.disc_1L = disc_1L;
data.disc_2L = disc_2L;
data.keff_drag_1L = keff_drag_1L;
data.keff_drag_2L = keff_drag_2L;
data.keff_serp = keff_serp;

plot(bu, disc_2L, ...
    'Marker', 'o', 'MarkerSize', 3, ...
    'DisplayName', '2L', ...
    'LineWidth', 1.2, 'LineStyle', '-', 'Color', 'blue')

plot(bu, disc_1L, ...
    'Marker', 'd', 'MarkerSize', 3, ...
    'DisplayName', '1L', ...
    'LineWidth', 1.2, 'LineStyle', '-', 'Color', 'green')

xlabel('$Burnup \ GWd/t$', 'Interpreter', 'latex');
yh2 = ylabel(h2, '$Discrepancy \ \Delta a \ pcm$', 'Interpreter', 'latex');
p2 = get(yh2, 'position');

% adjust ylabel position
p1(1) = p2(1);
set(yh1, 'position', p1);

grid(h2, 'on');
hold(h2, 'off');
lh2 = legend(h2, 'show', 'Location', 'East');
set(lh2, 'FontSize', 7);
set(figure1, 'Units', 'Inches');
pos = get(figure1, 'Position');
set(figure1, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)])
print(figure1, [plot_filename, '.eps'], '-depsc');
close(figure1)

end
