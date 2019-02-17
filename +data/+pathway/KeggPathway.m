classdef KeggPathway < handle
    %KEGGPATHWAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        keggThesaurus;
        
        fromTo;
        
        xOffset;
        
        nodeTable;
        relationTable;
    end
    
    methods
        
        function obj = init(obj, keggThesaurus)
            obj.keggThesaurus = keggThesaurus;
            
            obj.fromTo = []; % the node representing cell death, it is not connected to itself
            entityId     = {};
            type     = {};
            label    = {};
            x        = [];
            y        = [];
            
            obj.nodeTable = table(entityId, type, label, x, y);
            
            obj.xOffset =  0;
            
            
            type          = cell(0, 1);
            subType       = cell(0, 1);
            value         = cell(0, 1);
            from          = zeros(0,1);
            to            = zeros(0,1);
            
            obj.relationTable = table(from, to, type, subType, value);
            
        end
        
        function load(obj, filePath)
            domTree = xmlread(filePath);
            
            entryIdToNodeTableId = obj.loadNodesFromDomTree(domTree);
            obj.loadRelationsFromDomTree(domTree, entryIdToNodeTableId);
            obj.loadReactionsFromDomTree(domTree, entryIdToNodeTableId);
            
            obj.loadGroupRelations(domTree, entryIdToNodeTableId);
        end
        
        function loadFolder(obj, path)
            pathwayFiles = dir([path '*.xml']);
            
            for i = 1:length(pathwayFiles)
                pathwayFile = pathwayFiles(i).name;
                disp(['processing pathway file ' pathwayFile datestr(now)]);
                
                obj.load([path pathwayFile]);
            end
        end
        
        
        function loadReactionsFromDomTree(obj, domTree, entryIdToNodeTableId)
            reactionList = domTree.getElementsByTagName('reaction');
            
            reactionCount = reactionList.getLength();
            
            for i = 0:(reactionCount - 1)
                reaction = reactionList.item(i);
                
                substrateList = reaction.getElementsByTagName('substrate');
                productList   = reaction.getElementsByTagName('product');
                
                for s = 0:(substrateList.getLength - 1)
                for p = 0:(productList.getLength - 1)
                    substrate = substrateList.item(s);
                    product   = productList.item(p);
                    
                    fromIndex = entryIdToNodeTableId(char(substrate.getAttribute('id')));
                    toIndex   = entryIdToNodeTableId(char(product.getAttribute('id')));
                    
                    obj.fromTo(fromIndex, toIndex) = 1;
                end
                end
            end

        end
        
        function loadRelationsFromDomTree(obj, domTree, entryIdToNodeTableId)
            relationList = domTree.getElementsByTagName('relation');
            
            relationCount = relationList.getLength();
            relationSubtypeCount = domTree.getElementsByTagName('subtype').getLength();
            
%             for i = 1:(relationList.getLength()-1)
%                 relationCount = relationCount + relationList.item(i).getElementsByTagName('subtype');
%             end
%             
%             relationCount = relationList.getLength();
            type          = cell(relationSubtypeCount, 1);
            subType       = cell(relationSubtypeCount, 1);
            value         = cell(relationSubtypeCount, 1);
            from          = zeros(relationSubtypeCount,1);
            to            = zeros(relationSubtypeCount,1);
            
            addedRelationTable = table(from, to, type, subType, value);
            nextRelation = height(obj.relationTable) + 1;
            obj.relationTable = vertcat(obj.relationTable, addedRelationTable);
            
            % expand the matrix to fit the recently expanded node table
            newFromTo = zeros(height(obj.nodeTable));
            
            oldSize = size(obj.fromTo);
            newFromTo(1:oldSize(1), 1:oldSize(2)) = obj.fromTo(:,:);
            
            obj.fromTo = newFromTo; 
            
            % load all relations into the fromTo matrix
            for itemIndex = 0:(relationCount-1)
                relation = relationList.item(itemIndex);
                
                nextRelation = obj.insertRelation(relation, nextRelation, entryIdToNodeTableId);                
            end
        end
        
        function nextRelation = insertRelation(obj, relation, nextRelation, entryIdToNodeTableId)

            childNodes   = relation.getElementsByTagName('subtype');

            fromIndex = entryIdToNodeTableId(char(relation.getAttribute('entry1')));
            toIndex   = entryIdToNodeTableId(char(relation.getAttribute('entry2')));

            type = char(relation.getAttribute('type'));

            for i = 0:(childNodes.getLength() -1)
                subTypeNode  = childNodes.item(i);

                nextRelation = obj.insertRelationSubType(subTypeNode, fromIndex, toIndex, type, nextRelation, entryIdToNodeTableId);
            end

            % regulationEffect = obj.getRegulationEffect(relation);

            % obj.fromTo(fromIndex, toIndex) = obj.fromTo(fromIndex, toIndex) + regulationEffect;
        end
        
        function updateRegulationEffect(obj, fromIndex, toIndex, regulationEffect)
            currentRegulationEffect = obj.fromTo(fromIndex, toIndex);
            if (abs(regulationEffect) > abs(currentRegulationEffect))
                obj.fromTo(fromIndex, toIndex) = regulationEffect;
            end
        end
        
        function nextRelation = insertRelationSubType(obj, subTypeNode, fromIndex, toIndex, type, nextRelation, entryIdToNodeTableId)
            obj.relationTable.from(nextRelation)     = fromIndex;
            obj.relationTable.to(nextRelation)       = toIndex;
            obj.relationTable.type{nextRelation}     = type;
            
            subType = char(subTypeNode.getAttribute('name'));
            value   = char(subTypeNode.getAttribute('value'));
            
            obj.relationTable.subType{nextRelation}  = subType;
            obj.relationTable.value{nextRelation}    = value;
            
            if strcmp(subType, 'compound')
                compoundIndex = entryIdToNodeTableId(value);
                
                regulationEffect = obj.getRegulationEffect(subType);
                
                obj.updateRegulationEffect(fromIndex, compoundIndex, regulationEffect);                
                obj.updateRegulationEffect(compoundIndex, toIndex, regulationEffect);
                
                nextRelation = nextRelation + 1;
                return;
            end
            
            regulationEffect = obj.getRegulationEffect(subType);
            
            obj.updateRegulationEffect(fromIndex, toIndex, regulationEffect);
            
            nextRelation = nextRelation + 1;
            return;
        end
        
        function effect = getRegulationEffect(obj, relationSubType)
            
            switch (relationSubType)
                case 'expression'
                    effect = 1;
                case 'binding/association'
                    effect = 1;
                case 'activation'
                    effect = 1;
                case 'phosphorylation'
                    effect = .5;
                case 'indirect effect'
                    effect = .5;
                case 'missing interaction'
                    effect = .5; 
                case 'dephosphorylation'
                    effect = -.5; 
                case 'repression'
                    effect = -1;                
                case 'ubiquitination'
                    effect = -1;
                case 'dissociation'
                    effect = -1;
                case 'inhibition'
                    effect = -1;
                case 'group'
                    effect = 1;
                case 'compound'
                    effect = 1;
                case 'state change'
                    effect = .5;
            end
        end
        
        function tableIndex = getTableIndexOfEntityId(obj, entityId)
            tableIndex = find(cellfun(@(val) ~isempty(val) && val == entityId,obj.nodeTable.entityId), 1);
            % tableIndex = find(obj.nodeTable.entityId == entityId);
        end
        
        function isConnectionFromLabelToLabel = getIsConnectionFromLabelAToLabelB(obj, labelA, labelB)
            eidA = obj.keggThesaurus.getId(labelA);
            eidB = obj.keggThesaurus.getId(labelB);
            
            indexA = obj.getTableIndexOfEntityId(eidA);
            indexB = obj.getTableIndexOfEntityId(eidB);
            
            isConnectionFromLabelToLabel = obj.fromTo(indexA, indexB) ~= 0;
        end
        
        function isValid = isValidNode(obj, node)
            switch (char(node.getAttribute('type')))
                case 'group'
                    isValid = true;
                case 'compound'
                    isValid = true;
                case 'gene'
                    isValid = true;
                case 'ortholog'
                    isValid = true;
                case 'map'
                    isValid = true;
                otherwise
                    isValid = false;
            end
            
        end
        
        function validNodeCount = getValidNodeCount(obj, entryList)
            validNodeCount = 0;
            for i = 0:(entryList.getLength() - 1)
                item = entryList.item(i);
                if (obj.isValidNode(item))
                    validNodeCount = validNodeCount + 1;
                end
            end
        end
        
        function entryIdToNodeTableId = loadGroupRelations(obj, domTree, entryIdToNodeTableId)
            entryList = domTree.getElementsByTagName('entry');
            
            for itemIndex = 0:(entryList.getLength()-1)
                % extract essential data
                entry = entryList.item(itemIndex);
                
                if (~strcmp(entry.getAttribute('type'), 'group'))
                    continue;
                end
                
                groupId = entryIdToNodeTableId(char(entry.getAttribute('id')));
                
                componentList = entry.getElementsByTagName('component');
                
                for componentIndex = 0:(componentList.getLength() - 1)
                    component = componentList.item(componentIndex);
                    
                    componentId = entryIdToNodeTableId(char(component.getAttribute('id')));
                    
                    regulationEffect = obj.getRegulationEffect('group');
                    obj.updateRegulationEffect(groupId, componentId, regulationEffect);
                end
            end
        end
        function entryIdToNodeTableId = loadNodesFromDomTree(obj, domTree)
            entryList = domTree.getElementsByTagName('entry');
            
            % expand the size of the nodeTable to fit the unadded new nodes
            oldNodeCount = height(obj.nodeTable);
            
            addedNodeCount = obj.getValidNodeCount(entryList);
            
            entityId     = cell(addedNodeCount,1);
            type     = cell(addedNodeCount,1);
            label    = cell(addedNodeCount,1);
            x        = zeros(addedNodeCount,1);
            y        = zeros(addedNodeCount,1);
            addedNodeTable = table(entityId, type, label, x, y);
            
            obj.nodeTable = vertcat(obj.nodeTable, addedNodeTable);
            
            
            % bookkeeping vars:
            
            % the next unused position in the table
            nextTableIndex = oldNodeCount + 1;
            
            % a temporary mapping to relate file entry ids to table ids 
            entryIdToNodeTableId = containers.Map;
            
            % (it is possible that a new entry already exists in the table from
            % files that were added earlier that's why we need this mapping)
            
            for itemIndex = 0:(entryList.getLength()-1)
                % extract essential data
                entry = entryList.item(itemIndex);
                
                if (~obj.isValidNode(entry))
                    continue;
                end
                
                names = strsplit(char(entry.getAttribute('name')), ' ');
                
                if strcmp(names{1}, 'undefined')
                    names{1} = [datestr(now) '-' num2str(rand())];
                end
                
                entityId    = obj.keggThesaurus.getId(names{1});
                entryId = char(entry.getAttribute('id'));
                
                % establish position in table, and update entryId in file
                % to table position
                tableIndex = obj.getTableIndexOfEntityId(entityId);
                
                if ~isempty(tableIndex)
                    entryIdToNodeTableId(entryId) = tableIndex;
                    continue;
                end
                
                entryIdToNodeTableId(entryId) = nextTableIndex;

                % if entry not in table, retrieve all remaining data and
                % insert into table
                type = char(entry.getAttribute('type'));

                graphicsNode = entry.getElementsByTagName('graphics');
                graphicsNode = graphicsNode.item(0);
                label        = strsplit(char(graphicsNode.getAttribute('name')), ',');
                label        = label{1};
                
                x            = str2num(char(graphicsNode.getAttribute('x')));
                y            = str2num(char(graphicsNode.getAttribute('y')));
                
                obj.nodeTable.entityId{nextTableIndex}  = entityId;
                obj.nodeTable.type{nextTableIndex}  = type;
                obj.nodeTable.label{nextTableIndex} = label;
                obj.nodeTable.x(nextTableIndex)     = x+ obj.xOffset;
                obj.nodeTable.y(nextTableIndex)     = y;

                
                % finally update the next available table index
                nextTableIndex = nextTableIndex + 1;
            end
            % remove unnecessarily allocated node positions
            obj.nodeTable = obj.nodeTable(1:(nextTableIndex-1), :);  
            obj.xOffset = max(obj.nodeTable.x) + 20;
        end
        
        function entityIdArray = getEntityIdArray(obj)
            entityIdArray = obj.nodeTable.entityId; 
        end
       
        function matrix = getMatrix(obj)
            matrix = obj.fromTo;
        end
        
        function matrix = getMatrixWithTransitiveSteps(obj, stepCount)
            matrix = obj.fromTo;
            
            for i = 1:stepCount
                matrix = matrix + matrix * obj.fromTo;
            end
        end
        
        function matrix = getMatrixWithIncreasedLinkCount(obj, transitiveStepCount, mustIncludePotentialLinks)
            matrix = obj.getMatrixWithTransitiveSteps(transitiveStepCount);
            
            if mustIncludePotentialLinks
                potentialLinks = obj.findPotentialLinks();
                
                matrix = matrix + potentialLinks * .1;
            end
        end
        
        function shortestPaths = getShortestPaths(obj, network)
            connectivityGraph = digraph(sparse(network ~= 0));
            shortestPaths = distances(connectivityGraph);  
        end
        % the longest shortest path
        function diameter = getDiameter(obj, network)
            if (nargin == 1)
                network = obj.fromTo;
            end
            
            shortestPaths = obj.getShortestPaths(network);
            shortestPaths(shortestPaths == Inf) = 0;
                       
            diameter = max(max(shortestPaths));
        end
        
        function plotShortestPathLengthDistribution(obj, network)
            if (nargin < 2)
                network = obj.fromTo;
            end
            
            shortestPaths     = obj.getShortestPaths(network);
            pathLengths       = shortestPaths(1:end);
            pathLengths       = pathLengths(pathLengths ~= Inf);
            sortedPathLengths = sort(pathLengths, 'descend');
            axis('manual');
            plot(sortedPathLengths);
        end
        
        function potentialLinks = findPotentialLinks(obj)
            potentialTriangleLinks = obj.findPotentialTriangleLinks();
            potentialDorLinks = obj.findPotentialDORLinks();
            
            potentialLinks = potentialTriangleLinks + potentialDorLinks;
        end
        
        
        function potentialTriangleLinks = findPotentialTriangleLinks(obj)
            
            linkMatrix = obj.fromTo ~= 0;
            
            symmetricLinkMatrix = (+or(linkMatrix, linkMatrix'));
                        
            transitiveLink = symmetricLinkMatrix * symmetricLinkMatrix;
            
            transitiveLink(eye(size(transitiveLink)) ~= 0) = 0; % triangles should not be created by connecting nodes to themselves
            
            potentialTriangleLinks = (+and(transitiveLink, ~symmetricLinkMatrix));
        end
        
        function  potentialDorLinks = findPotentialDORLinks(obj)
            potentialDorLinks = zeros(size(obj.fromTo));
            for i = 1:size(obj.fromTo, 1)
                parentBIndexes = obj.fromTo(:, i) ~= 0;
                
                siblingThroughParentBIndexes = (sum(+(obj.fromTo(parentBIndexes, :) ~= 0), 1) ~= 0)';

                parentIIndexes               = find(parentBIndexes);
                siblingThroughParentIIndexes = find(siblingThroughParentBIndexes);
                
                for p = parentIIndexes
                for s = siblingThroughParentIIndexes
                    potentialDorLinks(p, s) = 1;
                    if size(potentialDorLinks,1) > 741
                        disp(i);
                        disp('too large');
                    end
                end
                end
            end
            
            for j = 1:size(obj.fromTo, 2)
                % Reverse this stuff, so get siblings via children 
                childBIndexes = obj.fromTo(j, :) ~= 0;
                
                siblingThroughChildBIndexes = sum(+(obj.fromTo(:, childBIndexes) ~= 0), 2) ~= 0;

                childIIndexes                = find(childBIndexes);
                siblingThroughChildIIndexes = find(siblingThroughChildBIndexes);
                 
                for c = childIIndexes
                for s = siblingThroughChildIIndexes'
                    potentialDorLinks(s, c) = 1;
                    if size(potentialDorLinks,1) > 741
                        disp(j);
                        disp('too large');
                    end
                end
                end                
            end
            
            potentialDorLinks(obj.fromTo ~= 0) = 0;
        end
        
        function siblingIndexes = getSiblings(obj, entityId)
            
            tableIndex = obj.getTableIndexOfEntityId(entityId);

            parentIndexes = obj.fromTo(:, tableIndex) ~= 0;
            
            unmergedSiblingIndexes = any(obj.fromTo(parentIndexes, :) ~= 0);
            
            siblingIndexes = obj.nodeTable.entityId(unmergedSiblingIndexes > 0);
        end
    end
    
    methods (Static)
        function entityIds = expandThesaurusFromKGML(thesauri, pathwayPath)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') ' data.pathway.KeggPathway.expandThesaurusFromKGML']);

            entityIds = sparse(0);
            entityIdCount = 0;
            
            kgmlFilePathArray = dir([pathwayPath '*.xml']);
            for i = 1:length(kgmlFilePathArray)
                nextKgmlFilePath = kgmlFilePathArray(i).name;
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'expanding thesauri with: ' nextKgmlFilePath]);

                domTree = xmlread([pathwayPath nextKgmlFilePath]);
                
                entries = domTree.getElementsByTagName('entry');
               
                for j = 0:(entries.getLength() - 1)
                    entry = entries.item(j);
                    
                    keggIds = strsplit(char(entry.getAttribute('name')), ' ');
                    
                    entityIdCount = entityIdCount + 1;
                    entityIds(entityIdCount) = thesauri.mergeSynonymArrayInsert('kegg', keggIds);
                end
            end
            
            entityIds = unique(entityIds);
        end
    end
    
end


