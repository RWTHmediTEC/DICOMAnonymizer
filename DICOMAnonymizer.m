function [anonFiles, notAnonFiles] = DICOMAnonymizer(DIR, ID)
%
% DICOMANONYMIZER tries to anonymize all DICOM files in a directory
%   
%   INPUT:
%       DIR: An attempt is being made to anonymize all DICOM files in this 
%          directory and in all subdirectories
%       ID: String to replace PatientName and PatientID
%
%   OUTPUT:
%          anonFiles: anonymized files
%       notAnonFiles: not anonymized files
%
%   TO-DO:
%       1. Warning: The attribute "PatientAdress" is not anonymized
%       2. Add attribUpdate and attribKeep as optional input and parse
%   
% AUTHOR: Maximilian C. M. Fischer
% 	mediTEC - Chair of Medical Engineering, RWTH Aachen University
% VERSION: 1.0
% DATE: 2016-09-23

addpath(genpath([fileparts([mfilename('fullpath'), '.m']) '\' 'src']))

p = inputParser;
addRequired(p,'DIR',@(x) isdir(x))
addRequired(p, 'ID',@(x)validateattributes(x,{'char'},{'nonempty'},2))
parse(p,DIR,ID)

DIR=p.Results.DIR;
ID=p.Results.ID;

% Updated attributes
attribUpdate.PatientName = ID;
attribUpdate.PatientID = ID;

% Kept attributes
% StudyInstanceUID & SeriesInstanceUID keep the hierarchy of a set of dicom files
attribKeep = {'PatientSex', 'PatientAge', 'StudyID', 'StudyDescription', 'SeriesDescription'...
    'StudyInstanceUID', 'SeriesInstanceUID'}; 

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