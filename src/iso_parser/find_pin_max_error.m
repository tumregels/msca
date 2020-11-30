function find_pin_max_error()
%find_pin_max_error Calculate maximum error in each pin for given isotope

clc;

run('pins_file_map.m');

%isotopes = {'U235', 'Pu239', 'Pu240', 'Pu241'};

isotopes = {'U235', 'U236', 'U238', 'Np237', ...
    'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242', ...
    'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};

data_dir = fileparts(s(length(s)).drag_burn_mat_filename);
file_name = fullfile(data_dir, 'pins_max_error.txt');
max_id = fopen(file_name, 'w');

for m = 1:numel(s)
    for i = 1:length(isotopes)
        analyse_and_report(m, s, det_map, isotopes{i}, max_id)
    end
end

fclose(max_id);
type(file_name);

end

function analyse_and_report(m, s, det_map, isotope_name, max_id)
pin_names = fieldnames(det_map);

drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
bu_steps = drag_bu_vs_keff(:, 1);

iso_data_1l = load(s(m).drag_burn_mat_filename);


data = struct;
l = 1;

for j = 1:numel(pin_names)
    pin_name = s(m).pin_name;
    
    drag_pin_data_1l = get_drag_pin_iso_dens( ...
        pin_name, isotope_name, s(m).mix_map, ...
        iso_data_1l.isotopes_mix, iso_data_1l.isotopes_dens, ...
        iso_data_1l.isotopes_used, iso_data_1l.volume_mix, ...
        bu_steps);
    
    serp_pin_data = get_serp_pin_iso_dens( ...
        pin_name, isotope_name, det_map, s(m).mix_map, s(m).serp_dep_filename);
    
    burnup_serp = serp_pin_data(5).burnup;
    burnup_drag_1l = drag_pin_data_1l(5).burnup;
    
    [~, pos_d] = intersect(burnup_drag_1l, burnup_serp);
    [~, pos_s] = intersect(burnup_serp, burnup_drag_1l);
    
    assert(all(burnup_serp(pos_s) == burnup_drag_1l(pos_d)) == 1)
    burnup_drag_1l = burnup_drag_1l(pos_d);
    
    for k = 1:numel(serp_pin_data)
        drag_1L = drag_pin_data_1l(k).iso_dens(pos_d);
        serp = serp_pin_data(k).iso_dens(pos_s);
        rel_error_1L = (100 * (1. - drag_1L ./ serp));
        % ignore initial 7 burnup steps due to oscillations in dragon
        rel_error_1L = rel_error_1L(7:end);
        burnup = burnup_drag_1l(7:end);
        
        [~, i1] = max(abs(rel_error_1L));
        ring = drag_pin_data_1l(k).ring_letter;
        
        %fprintf(max_id, 'pin:%s ring:%1s iso:%5s max_err_1L:%7.3f burnup:%6.3f\n', ...
        %    pin_name, ring, isotope_name, rel_error_1L(i1), burnup(i1));
        
        if k == numel(serp_pin_data)
            continue
        end
        
        data(l).pin_name = pin_name;
        data(l).ring = ring;
        data(l).burnup = burnup(i1);
        data(l).max_err_1L = rel_error_1L(i1);
        l = l + 1;
    end
end

[~, i1L] = max(abs([data(:).max_err_1L]));
%fprintf(max_id,'-------------\n');
% fprintf(max_id, ...
%     'pin:%s ring:%1s iso:%5s max_err:%7.3f burnup:%6.3f max_ave_err:%7.3f\n', ...
%     data(i1L).pin_name, data(i1L).ring, isotope_name, ...
%     data(i1L).max_err_1L, data(i1L).burnup,...
%     sum(abs([data(:).max_err_1L]))/length([data(:).max_err_1L]));
% for latex
fprintf(max_id, ...
    '%s & %1s & %5s & %7.3f & %6.2f \\\\ \n', ...
    data(i1L).pin_name, data(i1L).ring, isotope_name, ...
    data(i1L).max_err_1L, data(i1L).burnup);
%fprintf(max_id,'-------------\n');

end
