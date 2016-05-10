function runExperiment(flash_shower, word_shower, config, cancel_notify_fn)
%function runExperiment(flash_shower, word_shower, config, cancel_notify_fn)

light_image = imread('light.png');
dark_image = imread('dark.jpg');

    function showSignal(show_duration, pause_duration, num_flashes)
        for i = 1:num_flashes
             imshow(light_image, 'Parent', flash_shower);
             pause(show_duration);
             imshow(dark_image, 'Parent', flash_shower);
             pause(pause_duration);
        end
    end

    function [start, duration] = showWord(word)
        word_to_show = word.word;
        duration = config.show.duration;
        
        start = tic;
        
        set(word_shower, 'String', word_to_show);
        remaining_duration = duration - toc(start);

        if remaining_duration > 0
            pause(remaining_duration);
        end
        
        duration = toc(start);
    end

    showPause = @()set(word_shower, 'String', '--');
    
    function outputs = showWords()
        num_words = length(config.words);
        outputs = zeros(num_words, 3);
        
        for i = 1:num_words
            word = config.words(i);
            
            [start, duration] = showWord(word);
            
            outputs(i, 1) = start;
            outputs(i, 2) = duration;
            outputs(i, 3) = word.is_real;
            
            if(cancel_notify_fn())
                break;
            end
            
            showPause()
            pause(config.pause.duration);
        end
    end


start_signal = config.start_signal;
stop_signal = config.stop_signal;
showSignal(start_signal.show_duration, start_signal.pause_duration, start_signal.num_flashes);

if(cancel_notify_fn())
    return;
end

pause(1);

outputs = showWords();

set(word_shower, 'String', '--Complete--');

showSignal(stop_signal.show_duration, stop_signal.pause_duration, stop_signal.num_flashes);

dlmwrite('outputs.dat', outputs, 'precision', '%16d');

msgbox('complete');

end
