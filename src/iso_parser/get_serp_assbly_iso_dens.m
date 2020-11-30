function [assbly_struct] = get_serp_assbly_iso_dens( ...
    isotope_name, det_map, mix_map, dep_filename)
%get_serp_assbly_iso_dens Calculate assbly wise average iso density

pin_names = fieldnames(det_map);

fuel_volume = 0.0;
iso_dens_ave = [];

for i = 1:numel(pin_names)
    pin_name = pin_names{i};
    pin_data = get_serp_pin_iso_dens( ...
        pin_name, isotope_name, det_map, mix_map, dep_filename);
    
    for j = 1:numel(pin_data)
        if isempty(iso_dens_ave)
            iso_dens_ave = ...
                pin_data(j).iso_dens * pin_data(j).mix_volume;
        else
            iso_dens_ave = iso_dens_ave + ...
                pin_data(j).iso_dens * pin_data(j).mix_volume;
        end
        fuel_volume = fuel_volume + pin_data(j).mix_volume;
    end
end

assbly_struct.iso_dens_ave = iso_dens_ave / fuel_volume;
assbly_struct.fuel_volume = fuel_volume;
assbly_struct.burnup = pin_data(1).burnup;

end
