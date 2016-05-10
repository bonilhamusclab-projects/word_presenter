function c = config()
    c.pause.duration = 2;
    c.show.duration = .5;
    
    c.start_signal.num_flashes = 4;
    c.start_signal.show_duration = .1;
    c.start_signal.pause_duration = .05;
    
    c.stop_signal = c.start_signal;

    c.signal.num_flashes = 2;
    c.signal.show_duration = .5;
    c.signal.pause_duration = .5;
    
    fakes = data.fake_words();
    reals = data.real_words();
    words = [fakes reals];
    c.words = randsample(words, length(words));
    
    %uncomment to have quick demo
    %c.words = c.words(1:10);
end
