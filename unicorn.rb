worker_processes 4
listen 8888

after_fork do |server,worker|
  # require 'metasploit/concern/engine'


  msfbase = __FILE__
  while File.symlink?(msfbase)
    msfbase = File.expand_path(File.readlink(msfbase), File.dirname(msfbase))
  end
  msfdir = File.expand_path(File.join(File.dirname(msfbase), 'msfdir', 'lib'))
  $:.unshift(msfdir)

  require 'msfenv'

  require 'rex'
  require 'msf/ui'
  require 'msf/base'
  require 'msf/core/payload_generator'

  $framework = nil

  def init_framework(create_opts={})
    create_opts[:module_types] ||= [
      ::Msf::MODULE_PAYLOAD, ::Msf::MODULE_ENCODER, ::Msf::MODULE_NOP
    ]
    $framework = ::Msf::Simple::Framework.create(create_opts.merge('DisableDatabase' => true))
  end

  init_framework
end