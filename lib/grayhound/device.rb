module Grayhound
	class Device < Grayhound::Base
		attr_accessor :udid, :name
		def to_json(*a)
			{
				'udid' => udid,
				'name' => name
			}.to_json(*a)
		end
	end
end