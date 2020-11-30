function [pin_struct] = get_drag_pin_iso_dens( ...
    pin_name, iso_name, mix_map, ...
    isotopes_mix, isotopes_dens, isotopes_used, volume_mix, bu_steps)
%get_drag_pin_iso_dens Calculate dragon pin isotopic densities

rings = {'A', 'B', 'C', 'D', 'E', 'F'};

mixtures = mix_map.(pin_name);

pin_struct(length(mixtures)) = struct();

pin_volume = 0.0;
pin_iso_dens_x_vol = [];

iso_names = cell(length(isotopes_mix), 1);
for j = 1:length(isotopes_mix)
    name = isotopes_used{j};
    name = regexp(name, ' ', 'split');
    iso_names{j} = name{1};
end

for i = 1:length(mixtures)
    mix_number = mixtures(i);
    mix_idx = isotopes_mix == mix_number;
    
    iso_dens_cut = isotopes_dens(mix_idx, :);
    iso_names_cut = iso_names(mix_idx)';
    
    % idx = strfind(iso_names_cut, iso_name);
    idx = find(ismember(iso_names_cut, iso_name));
    if isempty(idx)
        idx = find(ismember(iso_names_cut, [iso_name, 'Gd']));
    end
    
    if isempty(idx)
        error(['isotope ', iso_name, ' not found'])
    end
    
    % idx = find(not(cellfun('isempty', idx)));
    pin_struct(i).iso_dens = iso_dens_cut(idx, :);
    pin_struct(i).burnup = bu_steps';
    pin_struct(i).mix_volume = volume_mix(mix_number);
    pin_struct(i).mix_number = mix_number;
    pin_struct(i).ring_letter = rings{i};
    pin_struct(i).pin_name = pin_name;
    
    pin_volume = pin_volume + volume_mix(mix_number);
    if isempty(pin_iso_dens_x_vol)
        pin_iso_dens_x_vol = pin_struct(i).iso_dens * pin_struct(i).mix_volume;
    else
        pin_iso_dens_x_vol = pin_iso_dens_x_vol + ...
            pin_struct(i).iso_dens * pin_struct(i).mix_volume;
    end
end

pin_struct(i+1).iso_dens = pin_iso_dens_x_vol / pin_volume;
pin_struct(i+1).burnup = bu_steps';
pin_struct(i+1).mix_volume = pin_volume;
pin_struct(i+1).mix_number = mixtures;
pin_struct(i+1).ring_letter = '';
pin_struct(i+1).pin_name = pin_name;

end
