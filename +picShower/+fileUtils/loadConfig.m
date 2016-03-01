function config = loadConfig(configFile)
  [~, configFileName, ext] = fileparts(configFile);
  
  if ~strcmp(ext, '.m')
      error('%s file type not supported', ext);
  end
  
  fn = str2func(configFileName);
  config = fn();

end