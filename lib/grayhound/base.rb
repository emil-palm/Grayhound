module Grayhound

	class Base
		def initialize(args=nil)
			if args
				args.keys.each do |arg|
					if self.respond_to? "#{arg}="
						self.send("#{arg}=", args[arg])
					end
				end
			end
		end
	end
end

require 'grayhound/device'
require 'grayhound/certificate'
require 'grayhound/provisioning_profile'
require 'grayhound/developer_center/base'