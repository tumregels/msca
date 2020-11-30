function [assbly_struct] = get_drag_assbly_iso_dens( ...
    isotope_name, mix_map, isotopes_mix, ...
    isotopes_dens, isotopes_used, volume_mix, bu_steps)
%get_drag_assbly_iso_dens Calculate assembly wise isotopic density

pin_names = fieldnames(mix_map);

fuel_volume = 0.0;

for i = 1:numel(pin_names)
    mixtures = mix_map.(pin_names{i});
    for j = 1:length(mixtures)
        mixture = mixtures(j);
        fuel_volume = fuel_volume + volume_mix(mixture);
    end
end

iso_dens_ave = [];

for i = 1:numel(pin_names)
    pin_name = pin_names{i};
    pin_data = get_drag_pin_iso_dens( ...
        pin_name, isotope_name, mix_map, isotopes_mix, ...
        isotopes_dens, isotopes_used, volume_mix, bu_steps);
    for j = 1:numel(pin_data) - 1
        if isempty(iso_dens_ave)
            iso_dens_ave = pin_data(j).iso_dens * ...
                pin_data(j).mix_volume / fuel_volume;
        else
            iso_dens_ave = iso_dens_ave + ...
                pin_data(j).iso_dens * pin_data(j).mix_volume / fuel_volume;
        end
    end
end

assbly_struct.iso_dens_ave = iso_dens_ave;
assbly_struct.burnup = bu_steps;
assbly_struct.fuel_volume = fuel_volume;

end
