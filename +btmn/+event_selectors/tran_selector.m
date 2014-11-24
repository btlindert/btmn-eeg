classdef event_selector < physioset.event.selector
% EVENT_SELECTOR - Selects TRAN events
% TRAN events occur at the onset of a manipulation block (i.e. at a transition)
   
    properties
        StimType   = 'TRAN';  % Type of the TRAN event       
        Negated    = false;
        DiscardMissingResp = true;
    end

    methods

        function [evArray, idx] = select(obj, evArray)            

            [stimEv, stimIdx] = select(evArray, 'Type', obj.StimType);
                        
            
            if isempty(stimEv),
                evArray = [];
                idx = [];
                return;
            end
           
           
            if obj.Negated,
                idx = setdiff(1:numel(evArray), stimIdx);
            else
                idx = stimIdx;
            end
            
            evArray = stimEv;       

        end
        
        function obj = not(obj)
           
            obj.Negated = ~obj.Negated;
            
        end

        % Constructor
        function obj = event_selector(varargin)

            if nargin < 1, return; end
            
            import misc.process_arguments;
            
            opt.StimType   = 'TRAN'; 
            opt.Negated    = false;
            opt.DiscardMissingResp = true;
            [~, opt] = process_arguments(opt, varargin);

            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
               obj.(fNames{i}) = opt.(fNames{i}); 
            end

        end

    end    

end