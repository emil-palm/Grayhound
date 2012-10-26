require 'stringio'
module Grayhound
	module DeveloperCenter
		APPLE_CERTIFICATE_URL = "http://www.apple.com/appleca/AppleIncRootCertificate.cer"

		@@agent = Mechanize.new
		@@agent.pluggable_parser.default = Mechanize::File
		@@agent.user_agent = Mechanize::AGENT_ALIASES['Mac Safari']
	

		def self.agent
			@@agent
		end

		proxy_regex = /:\/\/(.[^:]*):(\d*)/
		if ENV['https_proxy'] != nil && ENV['https_proxy'].match(proxy_regex) 
			Grayhound::DeveloperCenter::agent.set_proxy(Regexp.last_match(1), Regexp.last_match(2))
		end	

		def self.apple_certificate
			unless @@apple_certificate
				@@apple_certificate = StringIO.new
				Grayhound::DeveloperCenter::agent.download(Grayhound::DeveloperCenter::APPLE_CERTIFICATE_URL, @apple_certificate)
				@@apple_certificate.rewind
			end
			@@apple_certificate
		end

		class Base
		end
	end
end

require 'grayhound/developer_center/provisioning_profiles'
require 'grayhound/developer_center/certificates'
require 'grayhound/developer_center/devices'
require 'grayhound/developer_center/account'