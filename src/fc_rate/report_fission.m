function report_fission(nmix, merge, ngrpd, nbnus, nfall_s, nfall_d, ...
    prod, nftot_s_1g, nftot_d_1g, nfms, nfmd, results_fission)

fis_id = fopen(results_fission, 'w');

fprintf(fis_id, '\n========== %9s ==========\n', 'Fission');

nfall_s = (nfall_s / nfall_d) * prod;
nftot_s_1g(:) = nftot_s_1g(:) / nfall_s;
nfms(:, :) = nfms(:, :) / nfall_s;
nftot_d_1g(:) = nftot_d_1g(:) / prod;
nfmd(:, :) = nfmd(:, :) / prod;

nftot_s39 = zeros(1, 39);
nftot_d39 = zeros(1, 39);

for ibm = 1:nmix
    imerge = merge(ibm);
    if imerge == 0
        continue
    end
    nftot_s39(imerge) = nftot_s39(imerge) + nftot_s_1g(ibm);
    nftot_d39(imerge) = nftot_d39(imerge) + nftot_d_1g(ibm);
end

sums = 0.0;
sumd = 0.0;
maxerr = 0.0;
avgerr = 0.0;

fprintf(fis_id, '%19s %13s\n', 'serpent2', 'dragon5');
for imerge = 1:39
    sums = sums + nftot_s39(imerge);
    sumd = sumd + nftot_d39(imerge);
    err = 100.0 * (nftot_d39(imerge) - nftot_s39(imerge)) / nftot_s39(imerge);
    maxerr = max(maxerr, abs(err));
    avgerr = avgerr + abs(err);
    fprintf(fis_id, '%5d %13.5E %13.5E %6.2f\n', imerge, nftot_s39(imerge), nftot_d39(imerge), err);
end

avgerr = avgerr / real(39);
fprintf(fis_id, 'maxerr= %f  avgerr= %f\n', maxerr, avgerr);

pcm = zeros(1, nbnus);
rel = zeros(1, nbnus);

for ig = 1:ngrpd
    for iso = 1:nbnus
        pcm(iso) = (nfmd(iso, ig) - nfms(iso, ig)) * 1.0e5;
        rel(iso) = 100.0 * (nfmd(iso, ig) - nfms(iso, ig)) / nfms(iso, ig);
    end
    fprintf(fis_id, 'SERPENT-DRAGON comparisons\n');
    fprintf(fis_id, '%24s %12s %12s %12s %12s\n', 'grp', 'U235', 'U238', 'Pu239', 'Pu241');
    fprintf(fis_id, 'fission SERPENT2    :%3d %s\n', ig, sprintf(repmat('%12.5E ', 1, nbnus), nfms(1:nbnus, ig)));
    fprintf(fis_id, 'fission  DRAGON5    :%3d %s\n', ig, sprintf(repmat('%12.5E ', 1, nbnus), nfmd(1:nbnus, ig)));
    fprintf(fis_id, 'absolute error (pcm):%3d %s\n', ig, sprintf(repmat('%12.2f ', 1, nbnus), pcm(1:nbnus)));
    fprintf(fis_id, 'relative error   (%%):%3d %s\n', ig, sprintf(repmat('%12.2f ', 1, nbnus), rel(1:nbnus)));
    fprintf(fis_id, '--------------------\n');
end

fclose(fis_id);
type(results_fission);