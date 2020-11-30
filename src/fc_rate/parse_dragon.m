function [nfmd, ngmd, prod, nfall_d, ngall_d, nftot_d_1g, ngtot_d_1g] = ...
    parse_dragon(nmix, ngrpd, nbnus, filename)

[pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd] = ASCIIOpnv4(filename);
istate = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'STATE-VECTOR');

if istate(1) ~= nmix
    error('invalid number of mixtures')
end

nbiso = istate(2);

if istate(3) ~= ngrpd
    error('invalid number of groups')
end

imix = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESMIX ');
den = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESDENS');
vol = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESVOL ');
iso_used_str = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESUSED');
volume = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'MIXTURESVOL ');

fprintf(1, 'total volume = %9.5f\n', sum(volume));

hiso = cellstr(reshape(iso_used_str, 12, [])');

nftot_d_1g = zeros(1, nmix);
nfmd = zeros(nbnus, ngrpd);

ngtot_d_1g = zeros(1, nmix);
ngmd = zeros(nbnus, ngrpd);

x1 = zeros(1, ngrpd);
x2 = zeros(1, ngrpd);
x3 = zeros(1, ngrpd);
x4 = zeros(1, ngrpd);
prod = 0.0;

[pfin, ilvl, ~, CurRecInd] = ASCIISixv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESLIST', 1);

for iso = 1:nbiso
    
    if strcmp(hiso{iso}(1:4), 'U235')
        ity = 1;
    elseif strcmp(hiso{iso}(1:4), 'U238')
        ity = 2;
    elseif strcmp(hiso{iso}(1:5), 'Pu239')
        ity = 3;
    elseif strcmp(hiso{iso}(1:5), 'Pu241')
        ity = 4;
    else
        continue
    end
    
    vo = vol(iso);
    cc = den(iso);
    ibm = imix(iso);
    
    if ibm == 0
        continue
    end
    
    [pfin, ilvl, nbdata, CurRecInd] = ASCIISixv4( ...
        pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, ...
        sprintf('elt#%08d', iso), 1);
    
    if ~nbdata
        error('record does not exist elt#%08d', iso)
    end
    
    x1 = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'NG          ');
    x3 = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'NWT0        ');
    x2 = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'NFTOT       ');
    
    if any(x2)
        for ig = 1:ngrpd
            nftot_d_1g(ibm) = nftot_d_1g(ibm) + cc * x2(ig) * x3(ig) * vo;
            ngtot_d_1g(ibm) = ngtot_d_1g(ibm) + cc * x1(ig) * x3(ig) * vo;
        end
        x4 = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'NUSIGF      ');
        for ig = 1:ngrpd
            prod = prod + cc * x4(ig) * x3(ig) * vo;
        end
    else
        x2(:) = 0.0;
    end
    
    for ig = 1:ngrpd
        nfmd(ity, ig) = nfmd(ity, ig) + cc * x2(ig) * x3(ig) * vo;
        ngmd(ity, ig) = ngmd(ity, ig) + cc * x1(ig) * x3(ig) * vo;
        %fprintf(1, ...
        %    'ig=%2d vo=%8.5f cc=%8.5f NG=%10.5f NFTOT=%10.5f NWT0=%10.5f\n', ...
        %    ig, vo, cc, x1(ig), x2(ig), x3(ig));
    end
    
    [pfin, ilvl, ~, CurRecInd] = ASCIISixv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, ' ', 2);
end

fprintf(1, 'total neutron production in DRAGON = %8.5f\n', prod);

nfall_d = 0.0;
for ibm = 1:nmix
    nfall_d = nfall_d + nftot_d_1g(ibm);
end

ngall_d = 0.0;
for ibm = 1:nmix
    ngall_d = ngall_d + ngtot_d_1g(ibm);
end

fclose(pfin);