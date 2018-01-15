function [anonFiles, notAnonFiles] = DICOMAnonymizer(DIR, varargin)
%DICOMANONYMIZER tries to anonymize all DICOM files in a directory
%   
%   REQUIRED INPUT:
%       DIR: An attempt is being made to anonymize all DICOM files in this 
%          directory and in all subdirectories
%   OPTIONAL INPUT:
%       'PatientName': Replace the attribute 'PatientName'. 
%                      Default is 'Anonymous'.
%       'PatientID': Replace the attribute 'PatientID'.
%                    Default is 'Unknown'.
%       'SeriesDescription': Replace the attribute 'SeriesDescription'.
%                            By default the old value is kept.
%
%   OUTPUT:
%          anonFiles: anonymized files
%       notAnonFiles: not anonymized files
%
%   TODO:
%       1. Warning: The attribute "PatientAdress" is not anonymized. This 
%          bug has been reported to MATLAB.
%       2. Add attribKeep as optional input and parse
%   
% AUTHOR: Maximilian C. M. Fischer
% 	mediTEC - Chair of Medical Engineering, RWTH Aachen University
% VERSION: 1.0.3
% DATE: 2017-11-22
% LICENSE: Modified BSD License (BSD license with non-military-use clause)
%

addpath(genpath([fileparts([mfilename('fullpath'), '.m']) '\' 'src']))

p = inputParser;
addRequired(p,'DIR',@isdir)
addParameter(p,'PatientName','Anonymous', @(x)validateattributes(x,{'char'},{'nonempty'}))
addParameter(p,'PatientID','Unknown', @(x)validateattributes(x,{'char'},{'nonempty'}))
addParameter(p,'SeriesDescription',[], @(x) ischar(x) || isempty(x))
parse(p,DIR,varargin{:})

DIR=p.Results.DIR;

% Updated attributes
attribUpdate.PatientName = p.Results.PatientName;
attribUpdate.PatientID = p.Results.PatientID;
if ~isempty(p.Results.SeriesDescription)
    attribUpdate.SeriesDescription=p.Results.SeriesDescription;
end

% Kept attributes
% StudyInstanceUID & SeriesInstanceUID keep the hierarchy of a set of DICOM files
attribKeep = {'PatientSex', 'PatientAge', ...
    'StudyDate', 'AcquisitionDate', 'ContentDate',...
    'StudyTime', 'AcquisitionTime', 'ContentTime',...
    'StudyID', 'StudyDescription','StudyInstanceUID', 'SeriesInstanceUID'}; 

% List all files in the directory and in all subdirectories
files = dir([DIR, '\**\*.*']);
files([files.isdir])=[];

% Preallocation
anonFiles = cell2struct(cell(size(fieldnames(files)')), fieldnames(files)', 2);
notAnonFiles = cell2struct(cell(size(fieldnames(files)')), fieldnames(files)', 2);
anonError = struct('error', []);

warning('off','all')
textprogressbar('Anonymizing files:    ');
progressbarvector=round((1:length(files))/length(files)*100);
for f=1:length(files)
    try
        % Try to anonymize file
        tempFile = fullfile(files(f).folder, files(f).name);
        dicomanon(tempFile, tempFile, ...
            'keep', attribKeep, 'update', attribUpdate, 'UseVRHeuristic', false)
        anonFiles(f) = files(f);
    catch ME
        % If anonymization fails, add the file to the not anonymized files
        notAnonFiles(f) = files(f);
        anonError(f).error = ME;
    end
    textprogressbar(progressbarvector(f));
end
textprogressbar(' done');
warning('on','all')

% Remove empty fields
anonFiles = anonFiles(arrayfun(@(x) ~isempty(x.name), anonFiles));
notAnonFiles = notAnonFiles(arrayfun(@(x) ~isempty(x.name), notAnonFiles));
anonError = anonError(arrayfun(@(x) ~isempty(x.error), anonError));

% Copy the error
names = [fieldnames(notAnonFiles); fieldnames(anonError)];
notAnonFiles = cell2struct([struct2cell(notAnonFiles); struct2cell(anonError)], names, 1);

end