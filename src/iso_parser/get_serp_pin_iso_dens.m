function [pin_struct] = get_serp_pin_iso_dens( ...
    pin_name, iso_name, det_map, mix_map, dep_filename)
%get_serp_pin_iso_dens Extract isotopic density for specific pin

% load deplition data
run(dep_filename);

% get mat names
mat_names = who('-regexp', '^MAT_\w*_ADENS$');

rings = {'A', 'B', 'C', 'D', 'E', 'F'};

iso_number = eval(strcat('i', iso_name));

det_number = det_map.(pin_name);
mixtures = mix_map.(pin_name);

pin_volume = 0.0;
pin_iso_dens_x_vol = [];

pin_struct(length(mixtures)) = struct();

for i = 1:length(mixtures)
    
    if det_number == 0 % 0 for pin cell calculations
        det = rings{i};
    else % not zero for assembly calculations
        det = [num2str(det_number), '_', rings{i}];
    end
    
    mat_name_uox = ['MAT_UO2_', det, '_ADENS'];
    mat_name_gad = ['MAT_GADO_', det, '_ADENS'];
    
    vol_name_uox = ['MAT_UO2_', det, '_VOLUME'];
    vol_name_gad = ['MAT_GADO_', det, '_VOLUME'];
    
    if ismember(mat_name_uox, mat_names)
        mat_name = mat_name_uox;
        vol_name = vol_name_uox;
    elseif ismember(mat_name_gad, mat_names)
        mat_name = mat_name_gad;
        vol_name = vol_name_gad;
    end
    
    iso_dens_matrix = eval(mat_name);
    iso_dens = iso_dens_matrix(iso_number, :);
    
    vol = eval(vol_name);
    vol = vol(1);
    
    pin_struct(i).iso_dens = iso_dens;
    pin_struct(i).burnup = BU;
    pin_struct(i).mix_volume = vol;
    pin_struct(i).mix_number = mixtures(i);
    pin_struct(i).ring_letter = rings{i};
    pin_struct(i).pin_name = pin_name;
    
    pin_volume = pin_volume + pin_struct(i).mix_volume;
    if isempty(pin_iso_dens_x_vol)
        pin_iso_dens_x_vol = pin_struct(i).iso_dens * pin_struct(i).mix_volume;
    else
        pin_iso_dens_x_vol = pin_iso_dens_x_vol + ...
            pin_struct(i).iso_dens * pin_struct(i).mix_volume;
    end
end

pin_struct(i+1).iso_dens = pin_iso_dens_x_vol / pin_volume;
pin_struct(i+1).burnup = BU;
pin_struct(i+1).mix_volume = pin_volume;
pin_struct(i+1).mix_number = mixtures;
pin_struct(i+1).ring_letter = '';
pin_struct(i+1).pin_name = pin_name;

end
