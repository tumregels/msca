function report_capture(nmix, merge, ngrpd, nbnus, ngall_s, ngall_d, ...
    prod, ngtot_s_1g, ngtot_d_1g, ngms, ngmd, results_capture)

cap_id = fopen(results_capture, 'w');

fprintf(cap_id, '\n========== %9s ==========\n', 'Capture');

ngall_s = (ngall_s / ngall_d) * prod;
ngtot_s_1g(:) = ngtot_s_1g(:) / ngall_s;
ngms(:, :) = ngms(:, :) / ngall_s;
ngtot_d_1g(:) = ngtot_d_1g(:) / prod;
ngmd(:, :) = ngmd(:, :) / prod;

ngtot_s39 = zeros(1, 39);
ngtot_d39 = zeros(1, 39);

for ibm = 1:nmix
    imerge = merge(ibm);
    if imerge == 0
        continue
    end
    ngtot_s39(imerge) = ngtot_s39(imerge) + ngtot_s_1g(ibm);
    ngtot_d39(imerge) = ngtot_d39(imerge) + ngtot_d_1g(ibm);
end

sums = 0.0;
sumd = 0.0;
maxerr = 0.0;
avgerr = 0.0;

fprintf(cap_id, '%19s %13s\n', 'serpent2', 'dragon5');
for imerge = 1:39
    sums = sums + ngtot_s39(imerge);
    sumd = sumd + ngtot_d39(imerge);
    err = 100.0 * (ngtot_d39(imerge) - ngtot_s39(imerge)) / ngtot_s39(imerge);
    maxerr = max(maxerr, abs(err));
    avgerr = avgerr + abs(err);
    fprintf(cap_id, '%5d %13.5E %13.5E %6.2f\n', imerge, ngtot_s39(imerge), ngtot_d39(imerge), err);
end

avgerr = avgerr / 39;
fprintf(cap_id, 'maxerr= %f  avgerr= %f\n', maxerr, avgerr);

pcm = zeros(1, nbnus);
rel = zeros(1, nbnus);

for ig = 1:ngrpd
    for iso = 1:nbnus
        pcm(iso) = (ngmd(iso, ig) - ngms(iso, ig)) * 1.0e5;
        rel(iso) = 100.0 * (ngmd(iso, ig) - ngms(iso, ig)) / ngms(iso, ig);
    end
    fprintf(cap_id, 'SERPENT-DRAGON comparisons\n');
    fprintf(cap_id, '%24s %12s %12s %12s %12s\n', 'grp', 'U235', 'U238', 'Pu239', 'Pu241');
    fprintf(cap_id, 'capture SERPENT2    :%3d %s\n', ig, sprintf(repmat('%12.5E ', 1, nbnus), ngms(1:nbnus, ig)));
    fprintf(cap_id, 'capture  DRAGON5    :%3d %s\n', ig, sprintf(repmat('%12.5E ', 1, nbnus), ngmd(1:nbnus, ig)));
    fprintf(cap_id, 'absolute error (pcm):%3d %s\n', ig, sprintf(repmat('%12.2f ', 1, nbnus), pcm(1:nbnus)));
    fprintf(cap_id, 'relative error   (%%):%3d %s\n', ig, sprintf(repmat('%12.2f ', 1, nbnus), rel(1:nbnus)));
    fprintf(cap_id, '--------------------\n');
end

fclose(cap_id);
type(results_capture);