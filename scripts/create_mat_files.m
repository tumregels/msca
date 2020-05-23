clear;

function fileList = getAllFiles(dirName, fileExtension, appendFullPath)

  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirWithSubFolders = dir(dirName);
  dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
  fileList = {dirData.name}';  %'# Get a list of the files
  if ~isempty(fileList)
    if appendFullPath
      fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
  end
  subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
  end

end


function convert2mat(root, filetype)

    keepvars = {'i','ix', 'mfiles', 'keepvars', 'varlist', 'filetype'};

    mfiles = getAllFiles(root, filetype, 1);
    for i = 1:length(mfiles)
        filename = mfiles{i};
        disp(filename);
        run(filename);
        mat_filename = strrep(filename,'.m','.mat');
        save(mat_filename,'-v7');
        varlist = whos;
        for ix = 1:length(varlist)
            if ~strcmp(varlist(ix).name,keepvars)
                clear(varlist(ix).name);
            end
        end
    end

end


convert2mat('Serpent','*_res.m')
convert2mat('Serpent','*_dep.m')


disp('All mat files generated')
exit(0);