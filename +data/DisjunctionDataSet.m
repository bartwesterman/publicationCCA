classdef DisjunctionDataSet < data.UnionDataSet
    %DISJUNCTIONDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        elementsIncludedInDataSetArray;
        excludeElementsFromDataSetArray;
    end
    
    methods
        
        function obj = init(obj)
            elementsIncludedInDataSetArray  = {};
            excludeElementsFromDataSetArray = {};
        end
        
        function queryPattern = getPattern(obj)
            queryPattern = [data.UnionDataSet.getPattern(obj) ' WHERE ' obj.exclusionInclusionConstraintListSQL()];
        end

        function elementsMustExistIn(obj, dataSet)
            obj.addDataSet(dataSet);
            obj.elementsIncludedInDataSetArray{end + 1} = dataSet;
        end
        
        function excludeElementsIn(obj, dataSet)
            obj.excludeElementsFromDataSetArray{end + 1} = dataSet;
        end
        
        function constraintListSQL = exclusionInclusionConstraintListSQL(obj)
            constraintListSQL = [strjoin(cellfun(@obj.exclusionConstraintSQL, obj.excludeElementsFromDataSetArray), ' ') ' '...
                strjoin(cellfun(@obj.inclusionConstraintSQL, obj.elementsIncludedInDataSetArray))...
            ];
        end
        
        function constraintSQL = exclusionConstraintSQL(obj, dataSet)    
            constraintSQL = ['NOT EXISTS (' dataSet.getQuery() ')'];
        end
        
        function constraintSQL = inclusionConstraintSQL(obj, dataSet)    
            constraintSQL = ['EXISTS (' dataSet.getQuery() ')'];
        end
    end
    
end

