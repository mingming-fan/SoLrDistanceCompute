%%%algorithm to compute the distance between two sensor units

%some constants
%use the speed of sound at the temperature and air pressure 
%of the space where the data collection was conducted
speedofsound = 34300; % cm/s 
samplingrate = 44100;  % sampling rate of the audio files; change it accordingly
device1Speak2Mic = 1; % distance between the speaker and microphone of the sensor device 1 (unit: cm)
device2Speak2Mic = 1; % distance between the speaker and microphone of the sensor device 2 (unit: cm)
groundtruthDistance = 16.0; % the ground truth distance between the two sensor devices (unit: cm)

% probe audio file used in this experiment
[s2,fs2] = audioread('./data/sin20hz20000hz.wav');
targetsignal = (s2 - mean(s2)) / std(s2);

% place the probe files from one device into this folder
dataFolder1 = './data/experimentdata/device1';
outputfile1 = 'device1.csv';
fullname1 = fullfile(dataFolder1, outputfile1);
fid=fopen(fullname1,'w');
filePattern = fullfile(dataFolder1, '*.wav'); 
FileList1 = dir(filePattern);
N = size(FileList1,1);

disp('file names from the first folder')
for k = 1:N
    % get the file name:
    filename = FileList1(k).name;
    disp(filename);
    
    % process
    fullname = fullfile(dataFolder1,filename);
    [s1,fs1] = audioread(fullname);
    signal1 = (s1 - mean(s1))/std(s1);
    
    % search the first half to find the target signal 
    [c,lags]= xcorr(signal1(1: length(signal1)/2),targetsignal);
    idx = find(c == max(c));
    lag = lags(idx);
    
    [c2,lags2]= xcorr(signal1(length(signal1)/2+1: length(signal1)),targetsignal);
    idx2 = find(c2 == max(c2));
    lag2 = lags(idx2) + length(signal1)/2;
    fprintf(fid, '%d,%d \n', [lag,lag2]);
end
fclose(fid);


%place the probe files from the second device into this folder
dataFolder2 = './data/experimentdata/device2';
outputfile2 = 'device2.csv';
fullname2 = fullfile(dataFolder2, outputfile2);
fid=fopen(fullname2,'w');
filePattern = fullfile(dataFolder2, '*.wav'); 
FileList2 = dir(filePattern);

% the number of files should be exactly the same as the previous one
N2 = size(FileList2,1);

if N == N2
    disp('file names from the second folder')
    for k = 1:N2    
        % get the file name:
        filename = FileList2(k).name;
        disp(filename);

        % process
        fullname = fullfile(dataFolder2,filename);
        [s1,fs1] = audioread(fullname);
        signal1 = (s1 - mean(s1))/std(s1);
        
        [c,lags]= xcorr(signal1(1:length(signal1)/2),targetsignal);
        idx = find(c == max(c));
        lag = lags(idx);

        [c2,lags2]= xcorr(signal1(length(signal1)/2+1 : length(signal1)),targetsignal);
        idx2 = find(c2 == max(c2));
        lag2 = lags(idx2) + length(signal1)/2;
        fprintf(fid, '%d,%d \n', [lag,lag2]);
    end
    fclose(fid);

    %compute distance between the four timestampes fromt the two files and
    %save the result
    resultfilename = './data/experimentdata/result.csv';
    fid = fopen(resultfilename,'w');
    fprintf(fid, 'index,groundtruth,distance,distanceAdjust\r\n');
    data1 = csvread(fullname1);
    data2 = csvread(fullname2);
    for i = 1: length(data1)
       distance = abs(data1(i,2) - data1(i,1) - (data2(i,2) - data2(i,1))) * speedofsound / samplingrate / 2;  
       distanceAdjust = distance + device1Speak2Mic + device2Speak2Mic;
       fprintf(fid, '%d,%f,%f,%f\r\n', [i,groundtruthDistance,distance,distanceAdjust]);
    end
    fclose(fid);
    disp('finished.');
else
    disp('the number of files in the two data folders should be the same.');
end