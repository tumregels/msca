clc
clear

format short

logfile = 'process_iso_dens.log';

if exist(logfile, 'file') == 2
    delete(logfile);
end

is_octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if is_octave
    warning('off', 'all'); % suppress octave warnings
end

diary(logfile)

filedir = fileparts(mfilename('fullpath'));

s(1).nmix = 161;
s(1).bu_steps = 77;
s(1).tot_iso = 46664;
s(1).drag_burn_filename = fullfile(filedir, '/../../Dragon/2L/ASSBLY_A/output_2020-09-07_14-25-29/ASSBLY_CASEA_BURN2.txt');
s(1).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_2l.csv');
s(1).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_2l_first_cut.csv');
s(1).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_2l_last_cut.csv');
s(1).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_A/assbly_a_2l.mat');

s(2).nmix = 163;
s(2).bu_steps = 109;
s(2).tot_iso = 47262;
s(2).drag_burn_filename = fullfile(filedir, '/../../Dragon/2L/ASSBLY_B/output_2020-09-05_12-50-03/ASSBLY_CASEB_BURN2.txt');
s(2).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_2l.csv');
s(2).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_2l_first_cut.csv');
s(2).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_2l_last_cut.csv');
s(2).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_B/assbly_b_2l.mat');

s(3).nmix = 165;
s(3).bu_steps = 109;
s(3).tot_iso = 47860;
s(3).drag_burn_filename = fullfile(filedir, '/../../Dragon/2L/ASSBLY_C/output_2020-09-04_15-57-35/ASSBLY_CASEC_BURN2.txt');
s(3).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_2l.csv');
s(3).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_2l_first_cut.csv');
s(3).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_2l_last_cut.csv');
s(3).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_C/assbly_c_2l.mat');

s(4).nmix = 171;
s(4).bu_steps = 109;
s(4).tot_iso = 49654;
s(4).drag_burn_filename = fullfile(filedir, '/../../Dragon/2L/ASSBLY_D/output_2020-09-04_15-46-40/ASSBLY_CASED_BURN2.txt');
s(4).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_2l.csv');
s(4).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_2l_first_cut.csv');
s(4).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_2l_last_cut.csv');
s(4).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_D/assbly_d_2l.mat');

s(5) = s(1);
s(5).drag_burn_filename = fullfile(filedir, '/../../Dragon/1L/ASSBLY_A/output_2020-09-05_12-32-26/ASSBLY_CASEA_BURN2.txt');
s(5).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_1l.csv');
s(5).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_1l_first_cut.csv');
s(5).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_A/iso_dens_assbly_a_1l_last_cut.csv');
s(5).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_A/assbly_a_1l.mat');

s(6) = s(2);
s(6).drag_burn_filename = fullfile(filedir, '/../../Dragon/1L/ASSBLY_B/output_2020-09-05_12-47-05/ASSBLY_CASEB_BURN2.txt');
s(6).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_1l.csv');
s(6).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_1l_first_cut.csv');
s(6).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_B/iso_dens_assbly_b_1l_last_cut.csv');
s(6).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_B/assbly_b_1l.mat');

s(7) = s(3);
s(7).drag_burn_filename = fullfile(filedir, '/../../Dragon/1L/ASSBLY_C/output_2020-09-04_15-59-58/ASSBLY_CASEC_BURN2.txt');
s(7).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_1l.csv');
s(7).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_1l_first_cut.csv');
s(7).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_C/iso_dens_assbly_c_1l_last_cut.csv');
s(7).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_C/assbly_c_1l.mat');

s(8) = s(4);
s(8).drag_burn_filename = fullfile(filedir, '/../../Dragon/1L/ASSBLY_D/output_2020-09-04_15-51-08/ASSBLY_CASED_BURN2.txt');
s(8).csv_output_filename = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_1l.csv');
s(8).csv_output_filename_cut_first = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_1l_first_cut.csv');
s(8).csv_output_filename_cut_last = fullfile(filedir, '/../../data/ASSBLY_D/iso_dens_assbly_d_1l_last_cut.csv');
s(8).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_D/assbly_d_1l.mat');

s(9).nmix = 7;
s(9).bu_steps = 61;
s(9).tot_iso = 1206;
s(9).drag_burn_filename = fullfile(filedir, '/../../Dragon/PIN_A/output_2020-09-05_12-59-20/_BURN_rowland.txt');
s(9).csv_output_filename = fullfile(filedir, '/../../data/PIN_A/iso_dens_pin_a_1l.csv');
s(9).csv_output_filename_cut_first = fullfile(filedir, '/../../data/PIN_A/iso_dens_pin_a_1l_first_cut.csv');
s(9).csv_output_filename_cut_last = fullfile(filedir, '/../../data/PIN_A/iso_dens_pin_a_1l_last_cut.csv');
s(9).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_A/pin_a_1l.mat');

s(10) = s(9);
s(10).drag_burn_filename = fullfile(filedir, '/../../Dragon/PIN_B/output_2020-09-05_13-39-19/_BURN_rowland.txt');
s(10).csv_output_filename = fullfile(filedir, '/../../data/PIN_B/iso_dens_pin_b_1l.csv');
s(10).csv_output_filename_cut_first = fullfile(filedir, '/../../data/PIN_B/iso_dens_pin_b_1l_first_cut.csv');
s(10).csv_output_filename_cut_last = fullfile(filedir, '/../../data/PIN_B/iso_dens_pin_b_1l_last_cut.csv');
s(10).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_B/pin_b_1l.mat');

s(11) = s(9);
s(11).drag_burn_filename = fullfile(filedir, '/../../Dragon/PIN_C/output_2020-09-05_13-40-29/_BURN_rowland.txt');
s(11).csv_output_filename = fullfile(filedir, '/../../data/PIN_C/iso_dens_pin_c_1l.csv');
s(11).csv_output_filename_cut_first = fullfile(filedir, '/../../data/PIN_C/iso_dens_pin_c_1l_first_cut.csv');
s(11).csv_output_filename_cut_last = fullfile(filedir, '/../../data/PIN_C/iso_dens_pin_c_1l_last_cut.csv');
s(11).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_C/pin_c_1l.mat');

for i = 1:numel(s)

    out_folder = fileparts(s(i).drag_burn_mat_filename);
    if ~exist(fullfile(out_folder), 'dir')
        mkdir(fullfile(out_folder))
    end
    
    [pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd] = ASCIIOpnv4(s(i).drag_burn_filename);
    istate = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'STATE-VECTOR');
    
    assert(istate(3) == s(i).bu_steps, 'invalid number of burnup steps')
    assert(istate(4) == s(i).tot_iso, 'invalid number of isotopes')
    assert(istate(8) == s(i).nmix, 'invalid number of mixtures')
    
    fprintf(1, 'Number of burnup time stamps %d\n', istate(3));
    fprintf(1, 'Total number of isotopes %d\n', istate(4));
    fprintf(1, 'Number of depleting mixtures %d\n', istate(5));
    fprintf(1, 'Number of mixtures %d\n', istate(8));
    
    isotopes_mix = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESMIX ');
    depl_times = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'DEPL-TIMES  ');
    isotopes_used = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESUSED');
    isotopes_used = cellstr(reshape(isotopes_used, 12, [])');
    volume_mix = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'VOLUME-MIX  ');
    
    fprintf(1, 'Total volume = %9.5f\n', sum(volume_mix));
    
    isotopes_dens = zeros(s(i).tot_iso, s(i).bu_steps);
    steps = cell(1, s(i).bu_steps);
    
    for step = 1:s(i).bu_steps
        depl_step = sprintf('DEPL-DAT%04d', step);
        [pfin, ilvl, ~, CurRecInd] = ASCIISixv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, depl_step, 1);
        isotopes_dens(:, step) = ASCIIGetv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, 'ISOTOPESDENS');
        [pfin, ilvl, ~, CurRecInd] = ASCIISixv4(pfin, ilvl, RecordPos, RecordNumb, RecordName, CurRecInd, ' ', 2);
        steps{step} = strrep(depl_step, '-', '_');
    end
    
    save(s(i).drag_burn_mat_filename, ...
        'steps', 'isotopes_mix', 'isotopes_dens', ...
        'isotopes_used', 'volume_mix', ...
        '-v7');
    
    % load(s(i).drag_burn_mat_filename);
    
    % save all data
    % isotopes_dens_table = cell2table(num2cell(isotopes_dens),'VariableNames',steps);
    % T1 = [ table(isotopes_mix, isotopes_used, ...
    %     'VariableNames', {'ISOTOPESMIX' 'ISOTOPESUSED'}) isotopes_dens_table ];
    % writetable(T1,s(i).csv_output_filename,'Delimiter',',','QuoteStrings',true)
    
    % save first step data, ignore zeros
    burnup_first_step = isotopes_dens(:, 1);
    ind = burnup_first_step ~= 0.0;
    burnup_first_step_cut = burnup_first_step(ind);
    isotopes_mix_cut = isotopes_mix(ind);
    isotopes_used_cut = isotopes_used(ind);
    
    % table structure not available in octave
    if ~is_octave
        T3 = table(isotopes_mix_cut, isotopes_used_cut, burnup_first_step_cut, ...
            'VariableNames', {'ISOTOPESMIX', 'ISOTOPESUSED', 'DEPL_DAT0001'});
        writetable(T3, s(i).csv_output_filename_cut_first, 'Delimiter', ',', 'QuoteStrings', true)
    end
    
    % save last step data, ignore zeros
    burnup_last_step = isotopes_dens(:, end);
    ind = burnup_last_step ~= 0.0;
    burnup_last_step_cut = burnup_last_step(ind);
    isotopes_mix_cut = isotopes_mix(ind);
    isotopes_used_cut = isotopes_used(ind);
    
    if ~is_octave
        T3 = table(isotopes_mix_cut, isotopes_used_cut, burnup_last_step_cut, ...
            'VariableNames', {'ISOTOPESMIX', 'ISOTOPESUSED', 'DEPL_DAT0077'});
        writetable(T3, s(i).csv_output_filename_cut_last, 'Delimiter', ',', 'QuoteStrings', true)
    end
    
end

diary off