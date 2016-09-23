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
%       Add attribUpdate and attribKeep as optional input and parse
%   
% AUTHOR: Maximilian C. M. Fischer
% 	mediTEC - Chair of Medical Engineering, RWTH Aachen University
% VERSION: 1.0
% DATE: 2016-09-23

p = inputParser;
addRequired(p,'DIR',@(x) isdir(x))
addRequired(p, 'ID',@(x)validateattributes(x,{'char'},{'nonempty'},2))
parse(p,DIR,ID)

DIR=p.Results.DIR;
ID=p.Results.ID;

addpath(genpath([fileparts(mfilename('fullpath')) '\src']))

% Updated attributes
attribUpdate.PatientName = ID;
attribUpdate.PatientID = ID;

% Kept attributes
% StudyInstanceUID & SeriesInstanceUID keep the hierarchy of a set of dicom files
attribKeep = {'PatientSex', 'PatientAge', 'StudyID', 'StudyDescription', 'SeriesDescription'...
    'StudyInstanceUID', 'SeriesInstanceUID'}; 

% List all files in the directory and in all subdirectories
files = rdir([DIR, '\**\**.*']);
files = files(~[files.isdir]);

% Preallocation
anonFiles = struct('name',[], 'date',[], 'bytes',[], 'isdir',[], 'datenum', []);
notAnonFiles = struct('name',[], 'date',[], 'bytes',[], 'isdir',[], 'datenum', []);

warning('off','all')
for f=1:length(files)
    try
        % Try to anonymize file
        dicomanon(files(f).name, files(f).name, ...
            'keep', attribKeep, 'update', attribUpdate, 'UseVRHeuristic', false)
        anonFiles(f) = files(f);
    catch
        % If anonymization fails, add the file to the not anonymized files
        notAnonFiles(f) = files(f);
    end
end
warning('on','all')

% Remove empty fields
anonFiles = anonFiles(arrayfun(@(x) ~isempty(x.name), anonFiles));
notAnonFiles = notAnonFiles(arrayfun(@(x) ~isempty(x.name), notAnonFiles));

end