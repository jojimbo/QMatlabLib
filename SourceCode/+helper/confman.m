function [confman] = confman()
%CONFMAN Return an instance on the configuration manager singleton
    confman = engine.util.config.ConfMan.instance();
    %confman.disp;
end

