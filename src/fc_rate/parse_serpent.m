function [nfms, ngms, nfall_s, ngall_s, nftot_s_1g, ngtot_s_1g] = ...
    parse_serpent(nmix, ngrps, ngrpd, nbnus, hname, det_map, ...
    gd_cells, det_filename, dep_filename)

% load detector data
run(det_filename);

% extract variables with detector names
% starting with DET_C and ending with A,B,C,D,E or F
det_names = who('-regexp', '^DET_C\d{4}_[ABCDEF]$');

% load deplition data
run(dep_filename);

% get mat names
mat_names = who('-regexp', '^MAT_\w*_ADENS$');

% iso_map used to identify U235 and U238 rows in MAT_*_ADENS matrix
iso_map = [eval('iU235'), eval('iU238'), eval('iPu239'), eval('iPu241')];

% serpent detector structure
%
% det _C0X0X_X   de 1   dm X
%     dr 102 U235
%     dr 102 U238
%     dr 102 Pu239
%     dr 102 Pu241
%     dr -6 U235
%     dr -6 U238
%     dr -6 Pu239
%     dr -6 Pu241
%
% thus we have 2*length(iso_map) isotopes specified in the detector
% with similar order as in iso_map, where first half are for capture and
% next half for fission
det_iso_len = length(iso_map) * 2;

nftot = zeros(ngrps, nmix);
nftot_s_1g = zeros(1, nmix);
nfms = zeros(nbnus, ngrpd);

ngtot = zeros(ngrps, nmix);
ngtot_s_1g = zeros(1, nmix);
ngms = zeros(nbnus, ngrpd);

for ibm = 1:nmix
    if ismember(hname{ibm}, det_names)
        det_all_vals = eval(hname{ibm});
        det_vals = det_all_vals(:, 11);
        [mat_name, bu_step] = get_mat_name(mat_names, hname{ibm}, det_map, det_filename);
        iso_dens_matrix = eval(mat_name);
        for ig = 1:ngrps
            for jbin = 1:det_iso_len
                x = det_vals((ig - 1)*det_iso_len+jbin);
                if jbin > det_iso_len / 2 % fission
                    iso = jbin - det_iso_len / 2;
                    iso_dens = iso_dens_matrix(iso_map(iso), bu_step);
                    % fprintf(1,'%s F %18s %6.5E\n', hname{ibm}(5:9), mat_name, iso_dens);
                    nftot(ig, ibm) = nftot(ig, ibm) + x * iso_dens;
                    if (ig >= 3);
                        nfms(iso, 1) = nfms(iso, 1) + x * iso_dens;
                    end
                    if (ig <= 2);
                        nfms(iso, 2) = nfms(iso, 2) + x * iso_dens;
                    end
                else % capture
                    iso = jbin;
                    iso_dens = iso_dens_matrix(iso_map(iso), bu_step);
                    % fprintf(1,'%s C %18s %6.5E\n', hname{ibm}(5:9), mat_name, iso_dens);
                    ngtot(ig, ibm) = ngtot(ig, ibm) + x * iso_dens;
                    if (ig >= 3);
                        ngms(iso, 1) = ngms(iso, 1) + x * iso_dens;
                    end
                    if (ig <= 2);
                        ngms(iso, 2) = ngms(iso, 2) + x * iso_dens;
                    end
                end
            end
        end
    end
end

fprintf(1, '-------------\n');
for ig = 1:ngrpd
    str = sprintf(repmat('%6.5E  ', 1, nbnus), nfms(1:nbnus, ig));
    fprintf(1, 'fission SERPENT2: %d  %s\n', ig, str);
end
fprintf(1, '-------------\n');
for ig = 1:ngrpd
    str = sprintf(repmat('%6.5E  ', 1, nbnus), ngms(1:nbnus, ig));
    fprintf(1, 'capture SERPENT2: %d  %s\n', ig, str);
end
fprintf(1, '-------------\n');


nfall_s = 0.0;
for ibm = 1:nmix
    nftot_s_1g(ibm) = 0.0;
    for ig = 1:ngrps
        nftot_s_1g(ibm) = nftot_s_1g(ibm) + nftot(ig, ibm);
    end
    nfall_s = nfall_s + nftot_s_1g(ibm);
end

ngall_s = 0.0;
for ibm = 1:nmix
    ngtot_s_1g(ibm) = 0.0;
    for ig = 1:ngrps
        ngtot_s_1g(ibm) = ngtot_s_1g(ibm) + ngtot(ig, ibm);
    end
    ngall_s = ngall_s + ngtot_s_1g(ibm);
end

end

function [mat_name, bu_step] = ...
    get_mat_name(mat_names, det_name, det_map, det_filename)

% get_mat_name
% construct mat name (e.g. MAT_UO2_1_A_ADENS from _dep.m) and burnup step
% using detector name (e.g. DET_C0201_A)
% and detector filename ending number

bu_step = regexp(det_filename, '_det(?<step>\d*).m', 'names');
bu_step = str2num(bu_step.step) + 1;

raw_det_name = det_name(5:9);
ring_letter = det_name(end);
mat_number = num2str(det_map.(raw_det_name));
mat_name_uox = strcat('MAT_UO2_', mat_number, '_', ring_letter, '_ADENS');
mat_name_gad = strcat('MAT_GADO_', mat_number, '_', ring_letter, '_ADENS');

if ismember(mat_name_uox, mat_names)
    mat_name = mat_name_uox;
elseif ismember(mat_name_gad, mat_names)
    mat_name = mat_name_gad;
else
    error('could not find mat name for %20s', det_name)
end

end
