% plot 

% 
addpath(genpath('/data1/toolbox/fieldtrip'));

cfg             = [];
cfg.alpha       = 0.2;
cfg.parameter   = 'stat';
cfg.layout      = ft_stats.layout;
ft_clusterplot(cfg, ft_stats.stats);