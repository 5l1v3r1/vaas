$VERBOSE = nil

require 'pry'
require 'sinatra'
require 'uri'
require 'cgi'
require 'rack/protection'
require 'rack/protection/base'
require 'rack/protection/authenticity_token'
require 'rack/protection/escaped_params'
require 'rack/protection/form_token'
require 'rack/protection/json_csrf'
require 'rack/protection/frame_options'
require 'rack/protection/http_origin'
require 'rack/protection/ip_spoofing'
require 'rack/protection/path_traversal'
require 'rack/protection/remote_referrer'
require 'rack/protection/remote_token'
require 'rack/protection/session_hijacking'
require 'rack/protection/xss_header'
use Rack::Protection, :except => [:remote_token, :session_hijacking]

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

get '/payload' do
  content_type 'application/octet-stream'
  options = {
    cli: false,
    framework: $framework
  }
  opts = params.dup
  ['payload','format','encoder'].each do |opt|
    halt 400, "No #{opt} parameter!" unless opts.has_key? opt
    options[opt.to_sym] = ::CGI::unescape(opts[opt])
    opts.delete(opt)
  end
  ds = {}
  opts.each do |key, val|
    ds[key.upcase] = ::CGI::unescape(val)
  end
  options[:datastore] = ds
  venom_generator =  Msf::PayloadGenerator.new(options)
  payload = venom_generator.generate_payload
  response.headers['Content-Disposition'] = 'attachment; filename=payload.bin'
  return payload
end

