function runExperiment(flashShower, wordShower, config, cancelNotifyFn)
%function runExperiment(flashShower, wordShower, config, cancelNotifyFn)

lightImage = imread('light.png');
darkImage = imread('dark.jpg');

    function showSignal(showDuration, pauseDuration, numFlashes)
        for i = 1:numFlashes
             imshow(lightImage, 'Parent', flashShower);
             pause(showDuration);
             imshow(darkImage, 'Parent', flashShower);
             pause(pauseDuration);
        end
    end

    function [start, duration] = showWord(word)
        wordToShow = word.word;
        duration = config.show.duration;
        
        start = tic;
        
        showWordSub(wordToShow, 'Parent', wordShower);
        remainingDuration = duration - toc(start);

        if remainingDuration > 0
            pause(remainingDuration);
        end
        
        duration = toc(start);
    end
    
    function outputs = showWords()
        numWords = length(words);
        outputs = zeros(numWords, 3);
        
        for i = 1:numImages     
            word = words(i);
            
            [start, duration] = showWord(word);
            
            outputs(i, 1) = start;
            outputs(i, 2) = duration;
            outputs(i, 3) = word.is_real;
            
            if(cancelNotifyFn())
                break;
            end
            
	    showPauseSub(wordShower)
            pause(config.pause.duration);
        end
    end


startSignal = config.startSignal;
stopSignal = config.stopSignal;
showSignal(startSignal.showDuration, startSignal.pauseDuration, startSignal.numFlashes);

if(cancelNotifyFn())
    return;
end

pause(1);

outputs = showWords();

showWordSub('complete', 'Parent', wordShower);

showSignal(stopSignal.showDuration, stopSignal.pauseDuration, stopSignal.numFlashes);

dlmwrite('outputs.dat', outputs, 'precision', '%16d');

msgbox('complete');

end
