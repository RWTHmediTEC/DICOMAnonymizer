
% An attempt is being made to anonymize all DICOM files in this directory 
% and in all subdirectories

DICOM_path='X:\Insert\the\path\of\your\DICOM\directory\here';

[anonFiles, notAnonFiles] = DICOMAnonymizer(DICOM_path, 'Subject1234');

% Display the not anonyimzed files
disp('Not anonyimzed files:')
disp([{notAnonFiles.folder}', {notAnonFiles.name}'])