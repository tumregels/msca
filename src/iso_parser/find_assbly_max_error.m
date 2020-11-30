function find_assbly_max_error()
%find_assbly_max_error Calculate maximum error in each pin for given
% isotope and extract assembly wise maximum error and location
% for 1L and 2L cases

clc;

run('assbly_file_map.m');

%isotopes = {'U235', 'Pu239', 'Pu240', 'Pu241'};

isotopes = {'U235', 'U236', 'U238', 'Np237', ...
    'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242', ...
    'Sm147', 'Sm149', 'Sm150', 'Sm151', 'Sm152', 'Eu153'};

data_dir = fileparts(s(length(s)).drag_burn_mat_filename);
file_name = fullfile(data_dir, 'assbly_max_error_cut20.txt');
max_id = fopen(file_name, 'w');
fprintf(max_id, 'ASS   PIN R   ISO   ERR2L BURN2L   ERR1L BURN1L\n');

for m = 1:numel(s)
    for i = 1:length(isotopes)
        analyse_and_report(m, s, det_map, isotopes{i}, max_id)
        type(file_name);
    end
end

fclose(max_id);
end

function analyse_and_report(m, s, det_map, isotope_name, max_id)

pin_names = fieldnames(det_map);

drag_bu_vs_keff = get_drag_bu_vs_keff(s(m).drag_result_filename);
bu_steps = drag_bu_vs_keff(:, 1);

iso_data_2l = load(s(m).drag_burn_mat_filename);
iso_data_1l = load(s(m).drag_burn_mat_filename_1L);


data = struct;
l = 1;

%fprintf(max_id, 'isotope: %s\n',isotope_name);

for j = 1:numel(pin_names)
    pin_name = pin_names{j};
    
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
    burnup_drag_1l = drag_pin_data_1l(5).burnup;
    burnup_drag_2l = drag_pin_data_2l(5).burnup;
    
    [~, pos_d] = intersect(burnup_drag_1l, burnup_serp);
    [~, pos_s] = intersect(burnup_serp, burnup_drag_1l);
    
    assert(all(burnup_serp(pos_s) == burnup_drag_1l(pos_d)) == 1)
    assert(all(burnup_serp(pos_s) == burnup_drag_2l(pos_d)) == 1)
    burnup_drag_1l = burnup_drag_1l(pos_d);
    
    for k = 1:numel(serp_pin_data)
        drag_1L = drag_pin_data_1l(k).iso_dens(pos_d);
        drag_2L = drag_pin_data_2l(k).iso_dens(pos_d);
        serp = serp_pin_data(k).iso_dens(pos_s);
        rel_error_1L = (100 * (1. - drag_1L ./ serp));
        rel_error_2L = (100 * (1. - drag_2L ./ serp));
        % ignore initial burnup steps due to oscillations in dragon, start
        % from 1GWd/t
        if m == 1
            start = 8;
            rel_error_1L = rel_error_1L(start:end);
            rel_error_2L = rel_error_2L(start:end);
            burnup = burnup_drag_1l(start:end);
        else
            start = 20;
            rel_error_1L = rel_error_1L(start:end);
            rel_error_2L = rel_error_2L(start:end);
            burnup = burnup_drag_1l(start:end);
        end
        
        [~, i1] = max(abs(rel_error_1L));
        [~, i2] = max(abs(rel_error_2L));
        ring = drag_pin_data_2l(k).ring_letter;
        
        %fprintf(max_id, ...
        %    'pin:%s ring:%1s max_err_2L:%7.3f burnup:%6.3f max_err_1L:%7.3f burnup:%6.3f\n', ...
        %    pin_name, ring, rel_error_2L(i2), burnup(i2), rel_error_1L(i1), burnup(i1));
        
        if k == numel(serp_pin_data) - 1
            continue
        end
        
        data(l).pin_name = pin_name;
        data(l).ring = ring;
        data(l).max_err_2L = rel_error_2L(i2);
        data(l).burnup_2l = burnup(i2);
        data(l).max_err_1L = rel_error_1L(i1);
        data(l).burnup_1l = burnup(i1);
        l = l + 1;
    end
end

%fprintf(max_id,'-------------\n');
%fprintf(max_id,'pin sum abs 1L:%7.3f\n',sum(abs([data(:).max_err_1L])));
%fprintf(max_id,'pin sum abs 2L:%7.3f\n',sum(abs([data(:).max_err_2L])));
%fprintf(max_id,'pin ave abs 1L:%7.3f\n',sum(abs([data(:).max_err_1L]))/length([data(:).max_err_1L]));
%fprintf(max_id,'pin ave abs 2L:%7.3f\n',sum(abs([data(:).max_err_2L]))/length([data(:).max_err_2L]));
[~, i1L] = max(abs([data(:).max_err_1L]));
[~, i2L] = max(abs([data(:).max_err_2L]));

fprintf(max_id, ...
    '%3s %5s %1s %5s %7.3f %6.2f %7.3f %6.2f \n', ...
    s(m).assbly_name, data(i2L).pin_name, data(i2L).ring, isotope_name, ...
    data(i2L).max_err_2L, data(i2L).burnup_2l, data(i1L).max_err_1L, data(i1L).burnup_1l);

end
