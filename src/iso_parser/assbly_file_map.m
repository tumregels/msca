filedir = fileparts(mfilename('fullpath'));

s(1).drag_out_path = fullfile(filedir, '/../../Dragon/2L/ASSBLY_A/output_2020-09-07_14-25-29');
s(1).drag_result_filename = fullfile(s(1).drag_out_path, 'ASSBLY_CASEA.result');
s(1).drag_burn_filename = fullfile(s(1).drag_out_path, 'ASSBLY_CASEA_BURN2.txt');
s(1).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_A/assbly_a_2l.mat');
s(1).drag_out_path_1L = fullfile(filedir, '/../../Dragon/1L/ASSBLY_A/output_2020-09-05_12-32-26');
s(1).drag_result_filename_1L = fullfile(s(1).drag_out_path_1L, 'ASSBLY_CASEA.result');
s(1).drag_burn_filename_1L = fullfile(s(1).drag_out_path_1L, 'ASSBLY_CASEA_BURN2.txt');
s(1).drag_burn_mat_filename_1L = fullfile(filedir, '/../../data/ASSBLY_A/assbly_a_1l.mat');
s(1).serp_out_path = fullfile(filedir, '/../../Serpent/ASSBLY_A/output_2020-09-08_10-03-02');
s(1).serp_dep_filename = fullfile(s(1).serp_out_path, 'ASSBLY_CASEA_mc_dep.m');
s(1).serp_res_filename = fullfile(s(1).serp_out_path, 'ASSBLY_CASEA_mc_res.m');
s(1).assbly_name = 'A';
s(1).pin_names = {'C0505'}; % random pin, no Gd in Assembly A
s(1).gd_pins = {};
s(1).mix_map = struct( ...
    'C0201', [3, 4, 5, 6], ...
    'C0202', [9, 10, 11, 12], ...
    'C0301', [13, 14, 15, 16], ...
    'C0302', [17, 18, 19, 20], ...
    'C0303', [21, 22, 23, 24], ...
    'C0402', [26, 27, 28, 29], ...
    'C0403', [30, 31, 32, 33], ...
    'C0501', [34, 35, 36, 37], ...
    'C0502', [38, 39, 40, 41], ...
    'C0503', [42, 43, 44, 45], ...
    'C0504', [46, 47, 48, 49], ...
    'C0505', [50, 51, 52, 53], ...
    'C0601', [54, 55, 56, 57], ...
    'C0602', [58, 59, 60, 61], ...
    'C0603', [62, 63, 64, 65], ...
    'C0604', [66, 67, 68, 69], ...
    'C0605', [70, 71, 72, 73], ...
    'C0702', [74, 75, 76, 77], ...
    'C0703', [78, 79, 80, 81], ...
    'C0705', [82, 83, 84, 85], ...
    'C0706', [86, 87, 88, 89], ...
    'C0707', [90, 91, 92, 93], ...
    'C0801', [94, 95, 96, 97], ...
    'C0802', [98, 99, 100, 101], ...
    'C0803', [102, 103, 104, 105], ...
    'C0804', [106, 107, 108, 109], ...
    'C0805', [110, 111, 112, 113], ...
    'C0806', [114, 115, 116, 117], ...
    'C0807', [118, 119, 120, 121], ...
    'C0808', [122, 123, 124, 125], ...
    'C0901', [126, 127, 128, 129], ...
    'C0902', [130, 131, 132, 133], ...
    'C0903', [134, 135, 136, 137], ...
    'C0904', [138, 139, 140, 141], ...
    'C0905', [142, 143, 144, 145], ...
    'C0906', [146, 147, 148, 149], ...
    'C0907', [150, 151, 152, 153], ...
    'C0908', [154, 155, 156, 157], ...
    'C0909', [158, 159, 160, 161] ...
    );

s(2).drag_out_path = fullfile(filedir, '/../../Dragon/2L/ASSBLY_B/output_2020-09-05_12-50-03');
s(2).drag_result_filename = fullfile(s(2).drag_out_path, 'ASSBLY_CASEB.result');
s(2).drag_burn_filename = fullfile(s(2).drag_out_path, 'ASSBLY_CASEB_BURN2.txt');
s(2).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_B/assbly_b_2l.mat');
s(2).drag_out_path_1L = fullfile(filedir, '/../../Dragon/1L/ASSBLY_B/output_2020-09-05_12-47-05');
s(2).drag_result_filename_1L = fullfile(s(2).drag_out_path_1L, 'ASSBLY_CASEB.result');
s(2).drag_burn_filename_1L = fullfile(s(2).drag_out_path_1L, 'ASSBLY_CASEB_BURN2.txt');
s(2).drag_burn_mat_filename_1L = fullfile(filedir, '/../../data/ASSBLY_B/assbly_b_1l.mat');
s(2).serp_out_path = fullfile(filedir, '/../../Serpent/ASSBLY_B/output_2020-08-23_12-19-31');
s(2).serp_dep_filename = fullfile(s(2).serp_out_path, 'ASSBLY_CASEB_mc_dep.m');
s(2).serp_res_filename = fullfile(s(2).serp_out_path, 'ASSBLY_CASEB_mc_res.m');
s(2).assbly_name = 'B';
s(2).pin_names = {'C0603'};
s(2).gd_pins = {'C0603'};
s(2).mix_map = struct( ...
    'C0201', [3, 4, 5, 6], ...
    'C0202', [9, 10, 11, 12], ...
    'C0301', [13, 14, 15, 16], ...
    'C0302', [17, 18, 19, 20], ...
    'C0303', [21, 22, 23, 24], ...
    'C0402', [26, 27, 28, 29], ...
    'C0403', [30, 31, 32, 33], ...
    'C0501', [34, 35, 36, 37], ...
    'C0502', [38, 39, 40, 41], ...
    'C0503', [42, 43, 44, 45], ...
    'C0504', [46, 47, 48, 49], ...
    'C0505', [50, 51, 52, 53], ...
    'C0601', [54, 55, 56, 57], ...
    'C0602', [58, 59, 60, 61], ...
    'C0603', [62, 63, 64, 65, 66, 67], ...
    'C0604', [68, 69, 70, 71], ...
    'C0605', [72, 73, 74, 75], ...
    'C0702', [76, 77, 78, 79], ...
    'C0703', [80, 81, 82, 83], ...
    'C0705', [84, 85, 86, 87], ...
    'C0706', [88, 89, 90, 91], ...
    'C0707', [92, 93, 94, 95], ...
    'C0801', [96, 97, 98, 99], ...
    'C0802', [100, 101, 102, 103], ...
    'C0803', [104, 105, 106, 107], ...
    'C0804', [108, 109, 110, 111], ...
    'C0805', [112, 113, 114, 115], ...
    'C0806', [116, 117, 118, 119], ...
    'C0807', [120, 121, 122, 123], ...
    'C0808', [124, 125, 126, 127], ...
    'C0901', [128, 129, 130, 131], ...
    'C0902', [132, 133, 134, 135], ...
    'C0903', [136, 137, 138, 139], ...
    'C0904', [140, 141, 142, 143], ...
    'C0905', [144, 145, 146, 147], ...
    'C0906', [148, 149, 150, 151], ...
    'C0907', [152, 153, 154, 155], ...
    'C0908', [156, 157, 158, 159], ...
    'C0909', [160, 161, 162, 163] ...
    );

s(3).drag_out_path = fullfile(filedir, '/../../Dragon/2L/ASSBLY_C/output_2020-09-04_15-57-35');
s(3).drag_result_filename = fullfile(s(3).drag_out_path, 'ASSBLY_CASEC.result');
s(3).drag_burn_filename = fullfile(s(3).drag_out_path, 'ASSBLY_CASEC_BURN2.txt');
s(3).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_C/assbly_c_2l.mat');
s(3).drag_out_path_1L = fullfile(filedir, '/../../Dragon/1L/ASSBLY_C/output_2020-09-04_15-59-58');
s(3).drag_result_filename_1L = fullfile(s(3).drag_out_path_1L, 'ASSBLY_CASEC.result');
s(3).drag_burn_filename_1L = fullfile(s(3).drag_out_path_1L, 'ASSBLY_CASEC_BURN2.txt');
s(3).drag_burn_mat_filename_1L = fullfile(filedir, '/../../data/ASSBLY_C/assbly_c_1l.mat');
s(3).serp_out_path = fullfile(filedir, '/../../Serpent/ASSBLY_C/output_2020-08-31_18-19-22');
s(3).serp_dep_filename = fullfile(s(3).serp_out_path, 'ASSBLY_CASEC_mc_dep.m');
s(3).serp_res_filename = fullfile(s(3).serp_out_path, 'ASSBLY_CASEC_mc_res.m');
s(3).assbly_name = 'C';
s(3).pin_names = {'C0603'};
s(3).gd_pins = {'C0603', 'C0707'};
s(3).mix_map = struct( ...
    'C0201', [3, 4, 5, 6], ...
    'C0202', [9, 10, 11, 12], ...
    'C0301', [13, 14, 15, 16], ...
    'C0302', [17, 18, 19, 20], ...
    'C0303', [21, 22, 23, 24], ...
    'C0402', [26, 27, 28, 29], ...
    'C0403', [30, 31, 32, 33], ...
    'C0501', [34, 35, 36, 37], ...
    'C0502', [38, 39, 40, 41], ...
    'C0503', [42, 43, 44, 45], ...
    'C0504', [46, 47, 48, 49], ...
    'C0505', [50, 51, 52, 53], ...
    'C0601', [54, 55, 56, 57], ...
    'C0602', [58, 59, 60, 61], ...
    'C0603', [62, 63, 64, 65, 66, 67], ...
    'C0604', [68, 69, 70, 71], ...
    'C0605', [72, 73, 74, 75], ...
    'C0702', [76, 77, 78, 79], ...
    'C0703', [80, 81, 82, 83], ...
    'C0705', [84, 85, 86, 87], ...
    'C0706', [88, 89, 90, 91], ...
    'C0707', [92, 93, 94, 95, 96, 97], ...
    'C0801', [98, 99, 100, 101], ...
    'C0802', [102, 103, 104, 105], ...
    'C0803', [106, 107, 108, 109], ...
    'C0804', [110, 111, 112, 113], ...
    'C0805', [114, 115, 116, 117], ...
    'C0806', [118, 119, 120, 121], ...
    'C0807', [122, 123, 124, 125], ...
    'C0808', [126, 127, 128, 129], ...
    'C0901', [130, 131, 132, 133], ...
    'C0902', [134, 135, 136, 137], ...
    'C0903', [138, 139, 140, 141], ...
    'C0904', [142, 143, 144, 145], ...
    'C0905', [146, 147, 148, 149], ...
    'C0906', [150, 151, 152, 153], ...
    'C0907', [154, 155, 156, 157], ...
    'C0908', [158, 159, 160, 161], ...
    'C0909', [162, 163, 164, 165] ...
    );

s(4).drag_out_path = fullfile(filedir, '/../../Dragon/2L/ASSBLY_D/output_2020-09-04_15-46-40');
s(4).drag_result_filename = fullfile(s(4).drag_out_path, 'ASSBLY_CASED.result');
s(4).drag_burn_filename = fullfile(s(4).drag_out_path, 'ASSBLY_CASED_BURN2.txt');
s(4).drag_burn_mat_filename = fullfile(filedir, '/../../data/ASSBLY_D/assbly_d_2l.mat');
s(4).drag_out_path_1L = fullfile(filedir, '/../../Dragon/1L/ASSBLY_D/output_2020-09-04_15-51-08');
s(4).drag_result_filename_1L = fullfile(s(4).drag_out_path_1L, 'ASSBLY_CASED.result');
s(4).drag_burn_filename_1L = fullfile(s(4).drag_out_path_1L, 'ASSBLY_CASED_BURN2.txt');
s(4).drag_burn_mat_filename_1L = fullfile(filedir, '/../../data/ASSBLY_D/assbly_d_1l.mat');
s(4).serp_out_path = fullfile(filedir, '/../../Serpent/ASSBLY_D/output_2020-08-23_12-21-57');
s(4).serp_dep_filename = fullfile(s(4).serp_out_path, 'ASSBLY_CASED_mc_dep.m');
s(4).serp_res_filename = fullfile(s(4).serp_out_path, 'ASSBLY_CASED_mc_res.m');
s(4).assbly_name = 'D';
s(4).pin_names = {'C0301'};
s(4).gd_pins = {'C0301', 'C0505', 'C0601', 'C0707', 'C0804'};
s(4).mix_map = struct( ...
    'C0201', [3, 4, 5, 6], ...
    'C0202', [9, 10, 11, 12], ...
    'C0301', [13, 14, 15, 16, 17, 18], ...
    'C0302', [19, 20, 21, 22], ...
    'C0303', [23, 24, 25, 26], ...
    'C0402', [28, 29, 30, 31], ...
    'C0403', [32, 33, 34, 35], ...
    'C0501', [36, 37, 38, 39], ...
    'C0502', [40, 41, 42, 43], ...
    'C0503', [44, 45, 46, 47], ...
    'C0504', [48, 49, 50, 51], ...
    'C0505', [52, 53, 54, 55, 56, 57], ...
    'C0601', [58, 59, 60, 61, 62, 63], ...
    'C0602', [64, 65, 66, 67], ...
    'C0603', [68, 69, 70, 71], ...
    'C0604', [72, 73, 74, 75], ...
    'C0605', [76, 77, 78, 79], ...
    'C0702', [80, 81, 82, 83], ...
    'C0703', [84, 85, 86, 87], ...
    'C0705', [88, 89, 90, 91], ...
    'C0706', [92, 93, 94, 95], ...
    'C0707', [96, 97, 98, 99, 100, 101], ...
    'C0801', [102, 103, 104, 105], ...
    'C0802', [106, 107, 108, 109], ...
    'C0803', [110, 111, 112, 113], ...
    'C0804', [114, 115, 116, 117, 118, 119], ...
    'C0805', [120, 121, 122, 123], ...
    'C0806', [124, 125, 126, 127], ...
    'C0807', [128, 129, 130, 131], ...
    'C0808', [132, 133, 134, 135], ...
    'C0901', [136, 137, 138, 139], ...
    'C0902', [140, 141, 142, 143], ...
    'C0903', [144, 145, 146, 147], ...
    'C0904', [148, 149, 150, 151], ...
    'C0905', [152, 153, 154, 155], ...
    'C0906', [156, 157, 158, 159], ...
    'C0907', [160, 161, 162, 163], ...
    'C0908', [164, 165, 166, 167], ...
    'C0909', [168, 169, 170, 171] ...
    );

det_map = struct( ...
    'C0201', 1, ...
    'C0202', 2, ...
    'C0301', 3, ...
    'C0302', 4, ...
    'C0303', 5, ...
    'C0402', 6, ...
    'C0403', 7, ...
    'C0501', 8, ...
    'C0502', 9, ...
    'C0503', 10, ...
    'C0504', 11, ...
    'C0505', 12, ...
    'C0601', 13, ...
    'C0602', 14, ...
    'C0603', 15, ...
    'C0604', 16, ...
    'C0605', 17, ...
    'C0702', 18, ...
    'C0703', 19, ...
    'C0705', 20, ...
    'C0706', 21, ...
    'C0707', 22, ...
    'C0801', 23, ...
    'C0802', 24, ...
    'C0803', 25, ...
    'C0804', 26, ...
    'C0805', 27, ...
    'C0806', 28, ...
    'C0807', 29, ...
    'C0808', 30, ...
    'C0901', 31, ...
    'C0902', 32, ...
    'C0903', 33, ...
    'C0904', 34, ...
    'C0905', 35, ...
    'C0906', 36, ...
    'C0907', 37, ...
    'C0908', 38, ...
    'C0909', 39 ...
    );