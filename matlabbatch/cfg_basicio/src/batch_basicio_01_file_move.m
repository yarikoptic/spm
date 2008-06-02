%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 1775 $)
%-----------------------------------------------------------------------
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.type = 'cfg_files';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.name = 'Files to move/copy/delete';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.tag = 'files';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.filter = 'any';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.ufilter = '.*';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.dir = '';
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.num = [1 Inf];
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.check = [];
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.help = {'These files will be moved, copied or deleted.'};
matlabbatch{1}.menu_cfg{1}.menu_entry{1}.conf_files.def = [];
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.type = 'cfg_files';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.name = 'Move to';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.tag = 'moveto';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.filter = 'dir';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.ufilter = '.*';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.dir = '';
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.num = [1 1];
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.check = [];
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.help = {'Files will be moved to the specified directory.'};
matlabbatch{2}.menu_cfg{1}.menu_entry{1}.conf_files.def = [];
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.type = 'cfg_files';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.name = 'Copy to';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.tag = 'copyto';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.filter = 'dir';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.ufilter = '.*';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.dir = '';
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.num = [1 1];
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.check = [];
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.help = {'Files will be moved to the specified directory.'};
matlabbatch{3}.menu_cfg{1}.menu_entry{1}.conf_files.def = [];
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.type = 'cfg_entry';
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.name = 'Pattern';
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.tag = 'pattern';
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.strtype = 's';
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.extras = [];
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.num = [1 Inf];
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.check = [];
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.help = {'The regular expression pattern to look for.'};
matlabbatch{4}.menu_cfg{1}.menu_entry{1}.conf_entry.def = [];
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.type = 'cfg_entry';
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.name = 'Replacement';
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.tag = 'repl';
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.strtype = 's';
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.extras = [];
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.num = [1 Inf];
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.check = [];
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.help = {'This string (or pattern) will be inserted instead.'};
matlabbatch{5}.menu_cfg{1}.menu_entry{1}.conf_entry.def = [];
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.type = 'cfg_branch';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.name = 'Pattern/Replacement Pair';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.tag = 'patrep';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1) = cfg_dep;
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tname = 'Val Item';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tgt_spec = {};
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).sname = 'Entry: Pattern (cfg_entry)';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_output = substruct('()',{1});
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1) = cfg_dep;
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tname = 'Val Item';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tgt_spec = {};
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).sname = 'Entry: Replacement (cfg_entry)';
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_exbranch = substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_output = substruct('()',{1});
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.check = [];
matlabbatch{6}.menu_cfg{1}.menu_struct{1}.conf_branch.help = {};
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.type = 'cfg_repeat';
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.name = 'Pattern/Replacement List';
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.tag = 'patreplist';
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1) = cfg_dep;
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1).tname = 'Values Item';
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1).tgt_spec = {};
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1).sname = 'Branch: Pattern/Replacement Pair (cfg_branch)';
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1).src_exbranch = substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.values{1}(1).src_output = substruct('()',{1});
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.num = [1 Inf];
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.forcestruct = false;
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.check = [];
matlabbatch{7}.menu_cfg{1}.menu_struct{1}.conf_repeat.help = {'Regexprep supports a list of multiple patterns and corresponding replacements. These will be applied to the filename portion (without path, without extension) one after another. E.g., if your filename is ''testimage(.nii)'', and you replace ''test'' with ''xyz'' and ''xyzim'' with ''newtestim'', the final filename will be ''newtestimage.nii''.'};
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.type = 'cfg_menu';
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.name = 'Unique Filenames';
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.tag = 'unique';
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.labels = {
                                                             'Don''t Care'
                                                             'Append Index Number'
}';
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.values{1} = false;
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.values{2} = true;
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.check = [];
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.help = {
                                                           'If the regexprep operation results in identical output filenames for two or more input files, these can not be written/renamed to their new location without loosing data. If you are sure that your regexprep patterns produce unique filenames, you do not need to care about this.'
                                                           'If you choose to append a running number, it will be zero-padded to make sure alphabetical sort of filenames returns them in the same order as the input files are.'
}';
matlabbatch{8}.menu_cfg{1}.menu_entry{1}.conf_menu.def = [];
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.type = 'cfg_branch';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.name = 'Move and Rename';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.tag = 'moveren';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1) = cfg_dep;
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tname = 'Val Item';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tgt_spec = {};
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).sname = 'Files: Move to (cfg_files)';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_output = substruct('()',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1) = cfg_dep;
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tname = 'Val Item';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tgt_spec = {};
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).sname = 'Repeat: Pattern/Replacement List (cfg_repeat)';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_exbranch = substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_output = substruct('()',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1) = cfg_dep;
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).tname = 'Val Item';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).tgt_spec = {};
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).sname = 'Menu: Unique Filenames (cfg_menu)';
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).src_exbranch = substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).src_output = substruct('()',{1});
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.check = [];
matlabbatch{9}.menu_cfg{1}.menu_struct{1}.conf_branch.help = {'The input files will be moved to the specified target folder. In addition, their filenames (not paths, not extensions) will be changed by replacing regular expression patterns using MATLABs regexprep function. Please consult MATLAB help and HTML documentation for how to specify regular expressions.'};
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.type = 'cfg_branch';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.name = 'Copy and Rename';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.tag = 'copyren';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1) = cfg_dep;
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tname = 'Val Item';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).tgt_spec = {};
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).sname = 'Files: Copy to (cfg_files)';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{1}(1).src_output = substruct('()',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1) = cfg_dep;
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tname = 'Val Item';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).tgt_spec = {};
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).sname = 'Repeat: Pattern/Replacement List (cfg_repeat)';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_exbranch = substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{2}(1).src_output = substruct('()',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1) = cfg_dep;
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).tname = 'Val Item';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).tgt_spec = {};
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).sname = 'Menu: Unique Filenames (cfg_menu)';
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).src_exbranch = substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.val{3}(1).src_output = substruct('()',{1});
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.check = [];
matlabbatch{10}.menu_cfg{1}.menu_struct{1}.conf_branch.help = {'The input files will be copied to the specified target folder. In addition, their filenames (not paths, not extensions) will be changed by replacing regular expression patterns using MATLABs regexprep function. Please consult MATLAB help and HTML documentation for how to specify regular expressions.'};
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.type = 'cfg_const';
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.name = 'Delete';
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.tag = 'delete';
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.val{1} = false;
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.check = [];
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.help = {'The selected files will be deleted.'};
matlabbatch{11}.menu_cfg{1}.menu_entry{1}.conf_const.def = [];
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.type = 'cfg_choice';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.name = 'Action';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.tag = 'action';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1) = cfg_dep;
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1).tname = 'Values Item';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1).tgt_spec = {};
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1).sname = 'Files: Move to (cfg_files)';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{1}(1).src_output = substruct('()',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1) = cfg_dep;
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1).tname = 'Values Item';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1).tgt_spec = {};
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1).sname = 'Files: Copy to (cfg_files)';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{2}(1).src_output = substruct('()',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1) = cfg_dep;
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1).tname = 'Values Item';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1).tgt_spec = {};
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1).sname = 'Branch: Move and Rename (cfg_branch)';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1).src_exbranch = substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{3}(1).src_output = substruct('()',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1) = cfg_dep;
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1).tname = 'Values Item';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1).tgt_spec = {};
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1).sname = 'Branch: Copy and Rename (cfg_branch)';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1).src_exbranch = substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{4}(1).src_output = substruct('()',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1) = cfg_dep;
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1).tname = 'Values Item';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1).tgt_spec = {};
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1).sname = 'Const: Delete (cfg_const)';
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1).src_exbranch = substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.values{5}(1).src_output = substruct('()',{1});
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.check = [];
matlabbatch{12}.menu_cfg{1}.menu_struct{1}.conf_choice.help = {};
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.type = 'cfg_exbranch';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.name = 'Move/Delete Files';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.tag = 'file_move';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1) = cfg_dep;
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1).tname = 'Val Item';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1).tgt_spec = {};
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1).sname = 'Files: Files to move/copy/delete (cfg_files)';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{1}(1).src_output = substruct('()',{1});
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1) = cfg_dep;
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1).tname = 'Val Item';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1).tgt_spec = {};
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1).sname = 'Choice: Action (cfg_choice)';
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1).src_exbranch = substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.val{2}(1).src_output = substruct('()',{1});
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.prog = @cfg_run_file_move;
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.vout = @cfg_vout_file_move;
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.check = [];
matlabbatch{13}.menu_cfg{1}.menu_struct{1}.conf_exbranch.help = {'Move or delete files.'};
