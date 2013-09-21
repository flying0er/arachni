=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

def reset_options
    opts = Arachni::Options.instance
    opts.reset
    opts.rpc_address = 'localhost'

    opts.dir['plugins']        = fixtures_path + 'plugins/'
    opts.dir['modules']        = fixtures_path + 'modules/'
    opts.dir['fingerprinters'] = fixtures_path + 'fingerprinters/'
    opts.dir['logs']           = spec_path + 'support/logs/'

    opts
end

def reset_all
    Arachni::Framework.reset
    reset_options
    Arachni::HTTP.reset
end

def killall
    instance_killall
    dispatcher_killall
    web_server_killall
    process_killall
    process_kill_em
end
