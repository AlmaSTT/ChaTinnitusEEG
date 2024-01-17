
function EEGf=preproEEG(pathGDF,nameGDF,pathOUT,ICAname)
%By Alma Socorro Torres Torres
%version 2022.2
% ICAname: 'MARA','IClabel' or 'WICA'

 %[ALLEEG,~,CURRENTSET]=eeglab;
 close all
% (1)Load .set
          EEG = pop_biosig([pathGDF,'\',nameGDF]);
          EEGchan=EEG;
          nameGDF=replace(nameGDF,'.gdf','');
   
%(2)Remove DC
          EEG.data = EEG.data-mean(EEG.data,2);
          EEGchan=EEG;
%(3)Line noise
         EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',100,'plotfreqz',0);
         EEG.setname = [nameGDF 'raw'];
         pop_saveset(EEG, 'filename', [nameGDF 'raw'], 'filepath', pathOUT); 
%(4)Ephoc 
      %bad channel rejection
      EEGcr = pop_select( EEG, 'nochannel',{'EOG1' 'EOG2'});
      EEG= pop_clean_rawdata(EEG, 'FlatlineCriterion',10,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','off','Distance','Euclidian','WindowCriterion', 0.2 );
      EEG = pop_select( EEG, 'channel',{EEGcr.chanlocs.labels,'EOG1', 'EOG2'});
      EEG.setname = [nameGDF 'bch'];
      pop_saveset(EEG, 'filename', [nameGDF 'bch'], 'filepath', pathOUT);
         
%(7)Decomposing constant fixed-source noise/artifacts/signals (ICA)
          % (6.1)High-pass filtering @ 1hz
          EEGff = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',100,'plotfreqz',0);
          EEGica = pop_runica(EEGff, 'icatype', 'runica', ...
              'extended',1,'interrupt','off');
          EEG.icawinv = EEGica.icawinv;
          EEG.icasphere = EEGica.icasphere;
          EEG.icaweights = EEGica.icaweights;
          EEG.icachansind = EEGica.icachansind;
          EEG.setname = [nameGDF 'ica'];
          pop_saveset(EEG, 'filename', [nameGDF 'ica'], 'filepath', pathOUT); 
          EEG = pop_select( EEG, 'nochannel',{'EOG1' 'EOG2'});
          %(8)Remove ICs artifacts(ICA)
 for n=1:length(ICAname)
     ICApp=ICAname{n};
if strcmp(ICApp,'MARA')
    %pop_loadset('filename', [nameSET 'ica.set'], 'filepath', pathOUT);
    [~,EEGf,~] =processMARA( ALLEEG,EEG,CURRENTSET);
    EEGf = pop_subcomp(EEGf); 
elseif strcmp(ICApp,'IClabel')
    %EEG = pop_loadset('filename', [nameSET 'ica.set'], 'filepath', pathOUT);

    % Perform IC rejection using ICLabel scores and r.v. from dipole fitting.
    EEGf= iclabel(EEG);
    EEGf = pop_icflag(EEGf, [NaN NaN;0.75 1;0.75 1;0.75 1;0.75 1;0.75 1;0.75 1]);
    EEGf = pop_subcomp(EEGf,find(EEGf.reject.gcompreject),0,0);
elseif strcmp(ICApp,'WICA')
    %EEG = pop_loadset('filename', [nameSET 'ica.set'], 'filepath', pathOUT);
    channs = 1:EEG.nbchan;
    [wIC,A,~,~] = wICA(EEG.data(channs,:), [], 1, 0, EEG.srate);
                artifacts = A*wIC; 
                EEGf = EEG;
                EEGf.data(channs,:) = EEG.data(channs,:)-artifacts;

end
                 
                EEGfin = pop_interp(EEGf, chan, 'spherical' );
                EEGf.setname = [nameGDF ICApp 'clean'];
                pop_saveset(EEGf, 'filename', [nameGDF ICApp 'clean'], 'filepath', pathOUT);
                
 end
end
