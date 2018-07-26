%some constants
%use the speed of sound at the temperature and air pressure 
%of the space where the data collection was conducted
speedofsound = 34300; % cm/s 
samplingrate = 44100;  % sampling rate of the audio files; change it accordingly

%%%following parameters need to be set properly
n = 1; % change accordingly
rootFolder = "./data";
dataFolders = {'./data/device1', './data/device2','./data/device3'};

% number of clusters (closed and open spaces)
numClusters =2;

switch n
    case 1
        % ultrasound 1s
        [s2,fs2] = audioread('./data/probefiles/sweep17000hz20000hz3dbfs1s.wav');
        duration = 1;
    case 2
         % ultrasound 0.1s
        [s2,fs2] = audioread('./data/probefiles/sweep17000hz20000hz3dbfsdot1s.wav');
        duration = 0.1;
    case 3
         % ultrasound 0.5s
        [s2,fs2] = audioread('./data/probefiles/sweep17000hz20000hz3dbfsdot5s.wav');
        duration = 0.5;
    case 4
        % full range 1s
        [s2,fs2] = audioread('./data/probefiles/sweep20hz20000hz3dbfs1s.wav');
        duration = 1;
    case 5
        [s2,fs2] = audioread('./data/probefiles/sweep20hz20000hz3dbfsdot1s.wav');
        duration = 0.1;
    case 6
        [s2,fs2] = audioread('./data/probefiles/sweep20hz20000hz3dbfsdot5s.wav');
        duration = 0.5;
    otherwise
        disp('input value is wrong')
end

targetsignal = (s2 - mean(s2)) / std(s2);

NumFiles = 0;
for idx = 1: numel(dataFolders)
    dataFolder = dataFolders{idx};
    display(dataFolder);
    outputfile = 'result.csv';
    fullname = fullfile(dataFolder, outputfile);
    fid=fopen(fullname,'w');
    filePattern = fullfile(dataFolder, '*.wav'); 
    FileList = dir(filePattern);
    N = size(FileList,1);
    NumFiles = N;
    for k = 1:N
        % get the file name:
        filename = FileList(k).name;
        disp(filename);

        % process
        fullname = fullfile(dataFolder,filename);
        [s1,fs1] = audioread(fullname);
        signal1 = (s1 - mean(s1))/std(s1); 

        % search to find the target signal 
        lag = finddelay(targetsignal,signal1(1: length(signal1)));

        signalStrength = 0;
        for j = lag : lag + round(fs1 * duration)
            signalStrength = signalStrength + abs(s1(j));
        end
        fprintf(fid, '%d, %f\n', lag, signalStrength);
    end
    fclose(fid);
end

signalStrengthsFilename = fullfile(rootFolder,"SignalStrengths.csv");
fid = fopen(signalStrengthsFilename,'w');
results = zeros(numel(dataFolders),NumFiles);
for idx = 1: numel(dataFolders)
    dataFolder = dataFolders{idx};
    inputfile = 'result.csv';
    fullname = fullfile(dataFolder, inputfile);
    data = csvread(fullname);
    fprintf(fid, '%d,', idx);
    for i = 1: length(data)
        results(idx,i) = data(i,2);
        fprintf(fid, '%f,', results(idx,i));
    end
    fprintf(fid, '\n');
end
fclose(fid);

%disp(results);


[idx,C] = kmeans(results, numClusters);
disp(idx)

resultfilename = fullfile(rootFolder,"ClusterResults.csv");
fid = fopen(resultfilename,'w');

data = csvread(signalStrengthsFilename);

for i = 1: size(data,1)
    fprintf(fid, '%d,%d\n', idx(i), data(i,1));
end
fclose(fid);

disp('finished.'); 


