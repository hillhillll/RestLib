% COMA Science Group - University of Liege
% Francisco Gomez J - 2001
% Classification of neuronal components comming from ICA using a Neuronal
% Networks
% With collaboration of Andrea Soddu
% dirData: dir name with data comming from groupICA
% ncompo: number of components to be analyzed
% maskName: Mask name
% assignedMarks: neuronal or non-neuronal marks
% assignedProbs: probabilities assigned to each component
% Tr: repetition Time
% example of use:
% IC_selection('data\subj_1',30,'data\subj_1\icaAnaMask',2.0)
function [assignedMarks assignedProbs] = IC_selection(dirData,ncompo,maskName,time_course_name,Tr,restlib_path)
    selectedFeatures = 1:11;    
    maskData = load_nii(maskName);        
    
    % training
    ff = loadARFF([restlib_path '/trainingData/trainComplete.arff']);
    % train using the optimal parameters
    classTrain = trainWekaClassifier(ff,'functions.MultilayerPerceptron',{'-H','6','-L','0.7'});
    % classify each component  
    timeData = load_nii(time_course_name);
    for i=1:ncompo
        if i<=10
            cc = sprintf('000%d',i-1);
        else
            cc = sprintf('00%d',i-1);
        end
        dataCompSpatial = load_nii(sprintf('%s/components/vol%s.nii.gz',dirData,cc));    
        % compute the fingerprint for each available template        
        feature = computeFingerprintSpaceTime(dataCompSpatial.img,timeData.img(:,i),maskData.img,Tr);
        feature = feature(:,selectedFeatures);        
        
        % classification
        writeWeka(feature,[],'vecTemp');
        test = loadARFF('vecTemp.arff');
        [testClass classProb]= wekaClassify(test,classTrain);
        testClass = ~testClass;
        assignedMarks(i) = testClass;
        assignedProbs(i) = classProb(1,1);           
    end   
