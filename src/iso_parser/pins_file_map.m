filedir = fileparts(mfilename('fullpath'));

s(1).drag_out_path = fullfile(filedir, '/../../Dragon/PIN_A/output_2020-09-05_12-59-20');
s(1).drag_result_filename = fullfile(s(1).drag_out_path, 'PIN_A.result');
s(1).drag_burn_filename = fullfile(s(1).drag_out_path, '_BURN_rowland.txt');
s(1).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_A/pin_a_1l.mat');
s(1).serp_out_path = fullfile(filedir, '/../../Serpent/PIN_A/output_2020-08-31_18-24-07');
s(1).serp_dep_filename = fullfile(s(1).serp_out_path, 'PIN_CASEA_mc_dep.m');
s(1).serp_res_filename = fullfile(s(1).serp_out_path, 'PIN_CASEA_mc_res.m');
s(1).pin_name = 'A';
s(1).scheme = '1L';
s(1).mix_map = struct('A', [1, 5, 6, 7]);

s(2).drag_out_path = fullfile(filedir, '/../../Dragon/PIN_B/output_2020-09-05_13-39-19');
s(2).drag_result_filename = fullfile(s(2).drag_out_path, 'PIN_B.result');
s(2).drag_burn_filename = fullfile(s(2).drag_out_path, '_BURN_rowland.txt');
s(2).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_B/pin_b_1l.mat');
s(2).serp_out_path = fullfile(filedir, '/../../Serpent/PIN_B/output_2020-09-05_14-51-47');
s(2).serp_dep_filename = fullfile(s(2).serp_out_path, 'PIN_CASEB_mc_dep.m');
s(2).serp_res_filename = fullfile(s(2).serp_out_path, 'PIN_CASEB_mc_res.m');
s(2).pin_name = 'B';
s(2).scheme = '1L';
s(2).mix_map = struct('B', [1, 5, 6, 7]);

s(3).drag_out_path = fullfile(filedir, '/../../Dragon/PIN_C/output_2020-09-05_13-40-29');
s(3).drag_result_filename = fullfile(s(3).drag_out_path, 'PIN_C.result');
s(3).drag_burn_filename = fullfile(s(3).drag_out_path, '_BURN_rowland.txt');
s(3).drag_burn_mat_filename = fullfile(filedir, '/../../data/PIN_C/pin_c_1l.mat');
s(3).serp_out_path = fullfile(filedir, '/../../Serpent/PIN_C/output_2020-09-07_08-34-28');
s(3).serp_dep_filename = fullfile(s(3).serp_out_path, 'PIN_CASEC_mc_dep.m');
s(3).serp_res_filename = fullfile(s(3).serp_out_path, 'PIN_CASEC_mc_res.m');
s(3).pin_name = 'C';
s(3).scheme = '1L';
s(3).mix_map = struct('C', [1, 5, 6, 7]);

det_map = struct('A', 0, 'B', 0, 'C', 0);