
% An attempt is being made to anonymize all DICOM files in this directory 
% and in all subdirectories
DICOM_path = 'X:\Insert\the\path\of\your\DICOM\directory\here';

% Enter the new ID to replace PatientName and PatientID
PatientName = 'Subject1234';
PatientID = '1234';

% Anonymization function
[anonFiles, notAnonFiles] = DICOMAnonymizer(DICOM_path, ...
    'PatientName', PatientName,...
    'PatientID', PatientID);

% Display the not anonymized files
if ~isempty(notAnonFiles)
    disp('Not anonymized files:')
    for f=1:length(notAnonFiles)
        disp([fullfile(notAnonFiles(f).folder, notAnonFiles.name) ...
            ' - ' notAnonFiles(f).error.message])
    end
end