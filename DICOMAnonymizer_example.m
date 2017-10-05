
% An attempt is being made to anonymize all DICOM files in this directory 
% and in all subdirectories
DICOM_path='X:\Insert\the\path\of\your\DICOM\directory\here';

% Enter the new ID to replace PatientName and PatientID
NewID = 'Subject1234';

% Anonymization function
[anonFiles, notAnonFiles] = DICOMAnonymizer(DICOM_path, NewID);

% Display the not anonyimzed files
if ~isempty(notAnonFiles)
    disp('Not anonyimzed files:')
    disp([{notAnonFiles.folder}', {notAnonFiles.name}'])
end