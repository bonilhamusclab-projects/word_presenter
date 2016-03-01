function c = config()
    c.pause.duration = 2;
    c.show.duration = .5;

    c.signal.num_flashes = 2;
    c.signal.show_duration = .5;
    c.signal.pause_duration = .5;
    
    fakes = data.fake_words();
    reals = data.real_words();
    
    c.images = picShower.utils.interleave(abstracts, concretes);
end
